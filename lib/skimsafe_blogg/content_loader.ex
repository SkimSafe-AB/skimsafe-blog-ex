defmodule SkimsafeBlogg.ContentLoader do
  @moduledoc """
  GenServer that loads blog posts from markdown files during application startup.

  This ensures that posts are available in the database when the application starts,
  solving deployment issues where posts might not be present after a fresh deployment.

  The loader:
  - Runs automatically during application startup
  - Loads markdown files from priv/content/
  - Only loads posts if the database is empty or in configured environments
  - Provides detailed logging for deployment monitoring
  - Gracefully handles errors and missing files
  """

  use GenServer
  require Logger

  alias SkimsafeBlogg.{MarkdownParser, Repo, AutoTagger}
  alias SkimsafeBlogg.AI.ReadTimeEstimator
  alias SkimsafeBlogg.Resources.Post

  @name __MODULE__

  # Client API

  @doc """
  Start the ContentLoader GenServer.
  """
  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, opts, name: @name)
  end

  @doc """
  Trigger a manual content load (useful for testing or updates).
  """
  def load_content do
    GenServer.cast(@name, :load_content)
  end

  @doc """
  Check if content loading is enabled for the current environment.
  """
  def content_loading_enabled? do
    GenServer.call(@name, :content_loading_enabled?)
  end

  @doc """
  Get the current status of the content loader.
  """
  def status do
    GenServer.call(@name, :status)
  end

  # Server Callbacks

  @impl true
  def init(opts) do
    # Start loading content after a short delay to ensure the database is ready
    Process.send_after(self(), :load_content_on_startup, 1000)

    state = %{
      status: :initializing,
      last_load: nil,
      posts_loaded: 0,
      errors: [],
      opts: opts
    }

    Logger.info("[ContentLoader] Started, will load content shortly...")
    {:ok, state}
  end

  @impl true
  def handle_info(:load_content_on_startup, state) do
    if should_load_content?() do
      Logger.info("[ContentLoader] Starting content load on startup...")
      new_state = perform_content_load(state)
      {:noreply, new_state}
    else
      Logger.info("[ContentLoader] Content loading disabled for this environment")
      {:noreply, %{state | status: :disabled}}
    end
  end

  @impl true
  def handle_cast(:load_content, state) do
    Logger.info("[ContentLoader] Manual content load triggered...")
    new_state = perform_content_load(state)
    {:noreply, new_state}
  end

  @impl true
  def handle_call(:content_loading_enabled?, _from, state) do
    {:reply, should_load_content?(), state}
  end

  @impl true
  def handle_call(:status, _from, state) do
    status_info = %{
      status: state.status,
      last_load: state.last_load,
      posts_loaded: state.posts_loaded,
      errors: state.errors
    }
    {:reply, status_info, state}
  end

  # Private Functions

  defp should_load_content? do
    # Load content if:
    # 1. Explicitly enabled in config, OR
    # 2. No posts exist in the database, OR
    # 3. Running in production and SKIMSAFE_LOAD_CONTENT env var is set

    config_enabled = Application.get_env(:skimsafe_blogg, :load_content_on_startup, false)
    no_posts_exist = posts_count() == 0
    env_enabled = System.get_env("SKIMSAFE_LOAD_CONTENT") == "true"

    cond do
      config_enabled ->
        Logger.debug("[ContentLoader] Loading enabled by config")
        true
      no_posts_exist ->
        Logger.info("[ContentLoader] Loading enabled: no posts in database")
        true
      env_enabled ->
        Logger.info("[ContentLoader] Loading enabled by environment variable")
        true
      true ->
        Logger.debug("[ContentLoader] Content loading disabled")
        false
    end
  end

  defp posts_count do
    try do
      case Repo.query("SELECT COUNT(*) FROM posts", []) do
        {:ok, %{rows: [[count]]}} -> count
        _ -> 0
      end
    rescue
      _ -> 0
    end
  end

  defp perform_content_load(state) do
    start_time = System.monotonic_time(:millisecond)

    try do
      content_dir = get_content_directory()

      if File.exists?(content_dir) do
        Logger.info("[ContentLoader] Loading posts from: #{content_dir}")

        # Clear existing posts if configured to do so
        if should_clear_existing_posts?() do
          clear_existing_posts()
        end

        {loaded_count, errors} = load_posts_from_directory(content_dir)

        end_time = System.monotonic_time(:millisecond)
        duration = end_time - start_time

        if loaded_count > 0 do
          Logger.info("[ContentLoader] Successfully loaded #{loaded_count} posts in #{duration}ms")

          # Automatically run post-processing tasks
          run_post_processing(loaded_count)
        end

        if length(errors) > 0 do
          Logger.warning("[ContentLoader] Encountered #{length(errors)} errors during loading")
          Enum.each(errors, fn error -> Logger.error("[ContentLoader] #{error}") end)
        end

        %{
          state
          | status: :loaded,
            last_load: DateTime.utc_now(),
            posts_loaded: loaded_count,
            errors: errors
        }
      else
        error_msg = "Content directory not found: #{content_dir}"
        Logger.error("[ContentLoader] #{error_msg}")

        %{
          state
          | status: :error,
            last_load: DateTime.utc_now(),
            errors: [error_msg]
        }
      end
    rescue
      error ->
        error_msg = "Content loading failed: #{inspect(error)}"
        Logger.error("[ContentLoader] #{error_msg}")

        %{
          state
          | status: :error,
            last_load: DateTime.utc_now(),
            errors: [error_msg]
        }
    end
  end

  defp get_content_directory do
    # Try to find the content directory in different locations
    app_dir = Application.app_dir(:skimsafe_blogg)
    Path.join([app_dir, "priv", "content"])
  end

  defp should_clear_existing_posts? do
    # Only clear if explicitly configured to do so
    Application.get_env(:skimsafe_blogg, :clear_posts_on_load, false)
  end

  defp clear_existing_posts do
    Logger.info("[ContentLoader] Clearing existing posts...")
    case Repo.query("DELETE FROM posts", []) do
      {:ok, _} -> :ok
      error -> Logger.error("[ContentLoader] Failed to clear posts: #{inspect(error)}")
    end
  end

  defp load_posts_from_directory(content_dir) do
    content_dir
    |> File.ls!()
    |> Enum.filter(&String.ends_with?(&1, ".md"))
    |> Enum.reduce({0, []}, fn filename, {loaded_count, errors} ->
      file_path = Path.join(content_dir, filename)

      case load_single_post(file_path, filename) do
        :ok ->
          {loaded_count + 1, errors}
        {:error, error} ->
          error_msg = "Failed to load #{filename}: #{error}"
          {loaded_count, [error_msg | errors]}
      end
    end)
  end

  defp load_single_post(file_path, filename) do
    try do
      Logger.debug("[ContentLoader] Processing #{filename}...")

      {metadata, content} = MarkdownParser.parse_file(file_path)
      slug = MarkdownParser.filename_to_slug(filename)
      post_attrs = MarkdownParser.create_post_attrs(metadata, content, slug)

      # Insert into database using raw SQL to avoid Ash complexity during startup
      case insert_post(post_attrs) do
        {:ok, _} ->
          Logger.debug("[ContentLoader] ✅ Loaded: #{post_attrs.title}")
          :ok
        {:error, error} ->
          {:error, "Database insertion failed: #{inspect(error)}"}
      end
    rescue
      error -> {:error, "File processing failed: #{inspect(error)}"}
    end
  end

  defp insert_post(post_attrs) do
    # First check if post with this slug already exists
    check_sql = "SELECT id FROM posts WHERE slug = ?"

    case Repo.query(check_sql, [post_attrs.slug]) do
      {:ok, %{rows: []}} ->
        # Post doesn't exist, insert it
        insert_new_post(post_attrs)

      {:ok, %{rows: [[existing_id]]}} ->
        # Post exists, update it
        update_existing_post(existing_id, post_attrs)

      error ->
        {:error, error}
    end
  end

  defp insert_new_post(post_attrs) do
    sql = """
    INSERT INTO posts (
      id, title, slug, excerpt, content, author, author_email,
      tags, featured, published, published_at, read_time_minutes,
      view_count, inserted_at, updated_at
    ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
    """

    params = [
      post_attrs.id,
      post_attrs.title,
      post_attrs.slug,
      post_attrs.excerpt,
      post_attrs.content,
      post_attrs.author,
      post_attrs.author_email,
      Jason.encode!(post_attrs.tags),
      if(post_attrs.featured, do: 1, else: 0),
      if(post_attrs.published, do: 1, else: 0),
      post_attrs.published_at,
      post_attrs.read_time_minutes,
      post_attrs.view_count,
      post_attrs.inserted_at,
      post_attrs.updated_at
    ]

    case Repo.query(sql, params) do
      {:ok, _result} -> {:ok, :inserted}
      error -> {:error, error}
    end
  end

  defp update_existing_post(existing_id, post_attrs) do
    sql = """
    UPDATE posts SET
      title = ?,
      content = ?,
      author = ?,
      author_email = ?,
      tags = ?,
      featured = ?,
      published = ?,
      published_at = ?,
      read_time_minutes = ?,
      updated_at = ?
    WHERE id = ?
    """

    params = [
      post_attrs.title,
      post_attrs.content,
      post_attrs.author,
      post_attrs.author_email,
      Jason.encode!(post_attrs.tags),
      if(post_attrs.featured, do: 1, else: 0),
      if(post_attrs.published, do: 1, else: 0),
      post_attrs.published_at,
      post_attrs.read_time_minutes,
      DateTime.utc_now(),
      existing_id
    ]

    case Repo.query(sql, params) do
      {:ok, _result} -> {:ok, :updated}
      error -> {:error, error}
    end
  end

  # Post-processing functions

  defp run_post_processing(loaded_count) do
    Logger.info("[ContentLoader] Running post-processing for #{loaded_count} posts...")

    try do
      # 1. Auto-tag posts
      run_auto_tagging()

      # 2. Estimate read times
      run_read_time_estimation()

      Logger.info("[ContentLoader] Post-processing completed successfully")
    rescue
      error ->
        Logger.error("[ContentLoader] Post-processing failed: #{inspect(error)}")
    end
  end

  defp run_auto_tagging do
    Logger.info("[ContentLoader] Auto-tagging posts...")

    try do
      # Get all published posts that need tags
      case Post.list_all_posts() do
        {:ok, page} ->
          posts_needing_tags =
            page.results
            |> Enum.filter(fn post ->
              is_nil(post.tags) || post.tags == [] || post.tags == [""]
            end)

          if length(posts_needing_tags) > 0 do
            Logger.info("[ContentLoader] Found #{length(posts_needing_tags)} posts needing tags")

            posts_needing_tags
            |> Enum.each(fn post ->
              case AutoTagger.auto_tag_post(post) do
                {:ok, updated_post} ->
                  Logger.debug("[ContentLoader] ✓ Tagged: #{post.title}")
                {:error, error} ->
                  Logger.warning("[ContentLoader] Failed to tag #{post.title}: #{inspect(error)}")
              end
            end)
          else
            Logger.info("[ContentLoader] All posts already have tags")
          end

        {:error, error} ->
          Logger.error("[ContentLoader] Failed to fetch posts for tagging: #{inspect(error)}")
      end
    rescue
      error ->
        Logger.error("[ContentLoader] Auto-tagging failed: #{inspect(error)}")
    end
  end

  defp run_read_time_estimation do
    Logger.info("[ContentLoader] Estimating read times...")

    try do
      # Get all published posts that need read time estimation
      case Post.list_all_posts() do
        {:ok, page} ->
          posts_needing_read_time =
            page.results
            |> Enum.filter(fn post ->
              is_nil(post.read_time_minutes) || post.read_time_minutes == 0 || post.read_time_minutes <= 5
            end)

          if length(posts_needing_read_time) > 0 do
            Logger.info("[ContentLoader] Found #{length(posts_needing_read_time)} posts needing read time estimation")

            posts_needing_read_time
            |> Enum.each(fn post ->
              case estimate_post_read_time(post) do
                {:ok, read_time} ->
                  # Update read time using raw SQL
                  case update_post_read_time(post.id, read_time) do
                    {:ok, _} ->
                      Logger.debug("[ContentLoader] ✓ Read time estimated: #{post.title} - #{read_time} min")
                    {:error, error} ->
                      Logger.warning("[ContentLoader] Failed to update read time for #{post.title}: #{inspect(error)}")
                  end
                {:error, error} ->
                  Logger.warning("[ContentLoader] Failed to estimate read time for #{post.title}: #{inspect(error)}")
              end
            end)
          else
            Logger.info("[ContentLoader] All posts already have read time estimates")
          end

        {:error, error} ->
          Logger.error("[ContentLoader] Failed to fetch posts for read time estimation: #{inspect(error)}")
      end
    rescue
      error ->
        Logger.error("[ContentLoader] Read time estimation failed: #{inspect(error)}")
    end
  end

  defp estimate_post_read_time(post) do
    try do
      # Try AI estimation first, fall back to word count
      read_time = ReadTimeEstimator.estimate_read_time(post.content, :openai)

      if is_integer(read_time) and read_time > 0 do
        {:ok, read_time}
      else
        # Fallback to word count method (200 words per minute)
        word_count =
          post.content
          |> String.split(~r/\s+/)
          |> length()

        read_time = max(1, round(word_count / 200))
        {:ok, read_time}
      end
    rescue
      _ ->
        # Ultimate fallback based on content length
        read_time = max(1, round(String.length(post.content) / 1000))
        {:ok, read_time}
    end
  end

  defp update_post_read_time(post_id, read_time) do
    sql = "UPDATE posts SET read_time_minutes = ?, updated_at = ? WHERE id = ?"
    params = [read_time, DateTime.utc_now(), post_id]

    case Repo.query(sql, params) do
      {:ok, _result} -> {:ok, :updated}
      error -> {:error, error}
    end
  end
end