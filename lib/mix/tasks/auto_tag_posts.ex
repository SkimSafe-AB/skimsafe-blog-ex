defmodule Mix.Tasks.AutoTagPosts do
  @moduledoc """
  Mix task to automatically generate and update tags for blog posts.

  ## Examples

      # Auto-tag all published posts
      mix auto_tag_posts

      # Auto-tag a specific post by slug
      mix auto_tag_posts --slug getting-started-with-phoenix-liveview

      # Use AI-based tagging (requires OPENAI_API_KEY)
      mix auto_tag_posts --ai

      # Preview tags without updating posts
      mix auto_tag_posts --preview
  """

  use Mix.Task

  alias SkimsafeBlogg.AutoTagger
  alias SkimsafeBlogg.Resources.Post

  @shortdoc "Auto-tag blog posts using natural language processing"

  def run(args) do
    Mix.Task.run("app.start")

    {opts, _args, _invalid} =
      OptionParser.parse(args,
        switches: [
          slug: :string,
          ai: :boolean,
          preview: :boolean,
          help: :boolean
        ],
        aliases: [
          s: :slug,
          a: :ai,
          p: :preview,
          h: :help
        ]
      )

    if opts[:help] do
      show_help()
    else
      execute_auto_tagging(opts)
    end
  end

  defp execute_auto_tagging(opts) do
    cond do
      opts[:slug] ->
        auto_tag_single_post(opts[:slug], opts)

      true ->
        auto_tag_all_posts(opts)
    end
  end

  defp auto_tag_single_post(slug, opts) do
    Mix.Shell.IO.info("Auto-tagging post with slug: #{slug}")

    case Post.get_by_slug(slug) do
      {:ok, post} ->
        tags =
          if opts[:ai] do
            generate_tags_with_method(post, :ai)
          else
            generate_tags_with_method(post, :keyword)
          end

        if opts[:preview] do
          show_preview(post, tags)
        else
          update_post_tags(post, tags)
        end

      {:error, _} ->
        Mix.Shell.IO.error("Post with slug '#{slug}' not found")
    end
  end

  defp auto_tag_all_posts(opts) do
    Mix.Shell.IO.info("Auto-tagging all published posts...")

    case Post.list_published() do
      {:ok, %{results: posts}} when is_list(posts) ->
        total_posts = length(posts)
        Mix.Shell.IO.info("Found #{total_posts} published posts")

        posts
        |> Enum.with_index(1)
        |> Enum.each(fn {post, index} ->
          Mix.Shell.IO.info("Processing post #{index}/#{total_posts}: #{post.title}")

          tags =
            if opts[:ai] do
              generate_tags_with_method(post, :ai)
            else
              generate_tags_with_method(post, :keyword)
            end

          if opts[:preview] do
            show_preview(post, tags)
          else
            update_post_tags(post, tags)
          end
        end)

        Mix.Shell.IO.info("Auto-tagging completed!")

      {:ok, posts} when is_list(posts) ->
        total_posts = length(posts)
        Mix.Shell.IO.info("Found #{total_posts} published posts")

        posts
        |> Enum.with_index(1)
        |> Enum.each(fn {post, index} ->
          Mix.Shell.IO.info("Processing post #{index}/#{total_posts}: #{post.title}")

          tags =
            if opts[:ai] do
              generate_tags_with_method(post, :ai)
            else
              generate_tags_with_method(post, :keyword)
            end

          if opts[:preview] do
            show_preview(post, tags)
          else
            update_post_tags(post, tags)
          end
        end)

        Mix.Shell.IO.info("Auto-tagging completed!")

      {:error, reason} ->
        Mix.Shell.IO.error("Failed to list published posts: #{inspect(reason)}")
    end
  end

  defp generate_tags_with_method(post, method) do
    case method do
      :ai ->
        combined_text =
          [post.title, post.excerpt, post.content]
          |> Enum.reject(&is_nil/1)
          |> Enum.join(" ")

        AutoTagger.generate_tags_with_ai(combined_text)

      :keyword ->
        AutoTagger.generate_tags_for_post(post)
    end
  end

  defp show_preview(post, tags) do
    Mix.Shell.IO.info("  Title: #{post.title}")
    Mix.Shell.IO.info("  Current tags: #{inspect(post.tags)}")
    Mix.Shell.IO.info("  Suggested tags: #{inspect(tags)}")
    Mix.Shell.IO.info("  ---")
  end

  defp update_post_tags(post, tags) do
    case Post.update_tags(post.id, tags) do
      {:ok, _updated_post} ->
        Mix.Shell.IO.info("  ✓ Updated tags: #{inspect(tags)}")

      {:error, changeset} ->
        Mix.Shell.IO.error("  ✗ Failed to update tags: #{inspect(changeset.errors)}")
    end
  end

  defp show_help do
    Mix.Shell.IO.info("""
    Auto-tag blog posts using natural language processing

    ## Usage

        mix auto_tag_posts [options]

    ## Options

        --slug, -s    Auto-tag a specific post by slug
        --ai, -a      Use AI-based tagging (requires OPENAI_API_KEY)
        --preview, -p Preview suggested tags without updating
        --help, -h    Show this help message

    ## Examples

        # Auto-tag all published posts using keyword analysis
        mix auto_tag_posts

        # Auto-tag a specific post
        mix auto_tag_posts --slug getting-started-with-phoenix-liveview

        # Preview suggested tags without updating
        mix auto_tag_posts --preview

        # Use AI-based tagging (requires OPENAI_API_KEY environment variable)
        mix auto_tag_posts --ai

        # Preview AI-suggested tags for a specific post
        mix auto_tag_posts --slug my-post --ai --preview

    ## AI Integration

    To use AI-based tagging, set the OPENAI_API_KEY environment variable:

        export OPENAI_API_KEY=your_api_key_here
        mix auto_tag_posts --ai

    If the API key is not set, the task will fall back to keyword-based tagging.
    """)
  end
end
