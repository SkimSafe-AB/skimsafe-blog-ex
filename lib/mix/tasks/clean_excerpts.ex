defmodule Mix.Tasks.CleanExcerpts do
  @moduledoc """
  Mix task to clean markdown formatting from existing excerpts.

  Usage:
      mix clean_excerpts
  """

  use Mix.Task

  alias SkimsafeBlogg.{Repo, Resources.Post}

  @shortdoc "Clean markdown formatting from existing excerpts"

  def run(_args) do
    Mix.Task.run("app.start")

    Mix.Shell.IO.info("🧹 Cleaning markdown from existing excerpts...")

    # Get all posts with excerpts that contain markdown formatting
    case Post.list_all_posts() do
      {:ok, page} ->
        posts_to_clean =
          page.results
          |> Enum.filter(fn post ->
            excerpt = post.excerpt || ""
            String.contains?(excerpt, "**") || String.contains?(excerpt, "*") || String.contains?(excerpt, "`")
          end)

        count = length(posts_to_clean)

        if count > 0 do
          Mix.Shell.IO.info("📝 Found #{count} posts with markdown in excerpts")

          posts_to_clean
          |> Enum.with_index(1)
          |> Enum.each(fn {post, index} ->
            cleaned_excerpt = clean_excerpt(post.excerpt)

            # Update using raw SQL to avoid Ash complexity
            sql = "UPDATE posts SET excerpt = ?, updated_at = ? WHERE id = ?"
            params = [cleaned_excerpt, DateTime.utc_now(), post.id]

            case Repo.query(sql, params) do
              {:ok, _} ->
                Mix.Shell.IO.info("   #{index}/#{count} ✅ Cleaned: #{post.title}")
                Mix.Shell.IO.info("   Before: \"#{post.excerpt}\"")
                Mix.Shell.IO.info("   After:  \"#{cleaned_excerpt}\"")
              {:error, error} ->
                Mix.Shell.IO.error("   #{index}/#{count} ✗ Failed: #{post.title} - #{inspect(error)}")
            end
          end)
        else
          Mix.Shell.IO.info("✨ All excerpts are already clean!")
        end

      {:error, error} ->
        Mix.Shell.IO.error("✗ Failed to fetch posts: #{inspect(error)}")
    end

    Mix.Shell.IO.info("\n✅ Excerpt cleaning completed!")
  end

  defp clean_excerpt(nil), do: "Learn more about this topic."
  defp clean_excerpt(""), do: "Learn more about this topic."

  defp clean_excerpt(excerpt) do
    excerpt
    |> String.trim()
    |> String.replace(~r/\*\*([^*]+)\*\*/, "\\1") # Remove bold formatting
    |> String.replace(~r/\*([^*]+)\*/, "\\1") # Remove italic formatting
    |> String.replace(~r/`([^`]+)`/, "\\1") # Remove inline code formatting
    |> String.replace(~r/\[([^\]]+)\]\([^)]+\)/, "\\1") # Remove links, keep text
    |> String.replace(~r/^"|"$/, "") # Remove surrounding quotes
    |> String.trim()
  end
end