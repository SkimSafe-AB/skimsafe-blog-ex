defmodule Mix.Tasks.GenerateExcerpts do
  @moduledoc """
  Mix task to automatically generate concise excerpts/summaries for blog posts.

  ## Examples

      mix generate_excerpts
      mix generate_excerpts --preview
      mix generate_excerpts --post elixir-basics-for-beginners

  """

  use Mix.Task

  alias SkimsafeBlogg.Resources.Post
  require Logger

  @shortdoc "Generate excerpts for blog posts using AI"

  @impl Mix.Task
  def run(args) do
    Mix.Task.run("app.start")

    {opts, _args} =
      OptionParser.parse!(args,
        switches: [preview: :boolean, post: :string],
        aliases: [p: :preview]
      )

    cond do
      opts[:post] ->
        # Generate excerpt for a specific post
        generate_excerpt_for_post(opts[:post], opts[:preview])

      opts[:preview] ->
        # Preview excerpts for all posts without updating
        preview_all_excerpts()

      true ->
        # Generate excerpts for all posts that don't have them
        generate_excerpts_for_all()
    end
  end

  defp generate_excerpts_for_all do
    Mix.Shell.IO.info("🔍 Finding posts without excerpts...")

    # Get published posts that have empty or missing excerpts
    case Post.list_all_posts() do
      {:ok, page} ->
        posts_without_excerpts =
          page.results
          |> Enum.filter(fn post ->
            is_nil(post.excerpt) || String.trim(post.excerpt) == ""
          end)

        count = length(posts_without_excerpts)
        Mix.Shell.IO.info("📝 Found #{count} posts to process")

        posts_without_excerpts
        |> Enum.with_index(1)
        |> Enum.each(fn {post, index} ->
          Mix.Shell.IO.info("📖 Processing #{index}/#{count}: #{post.title}")

          case generate_excerpt_with_ai(post) do
            {:ok, excerpt} ->
              case Post.update_excerpt(post.id, excerpt) do
                {:ok, _updated_post} ->
                  Mix.Shell.IO.info("   ✅ Generated excerpt: \"#{String.slice(excerpt, 0, 80)}...\"")

                {:error, changeset} ->
                  Mix.Shell.IO.error("   ✗ Failed to update excerpt: #{inspect(changeset.errors)}")
              end

            {:error, reason} ->
              Mix.Shell.IO.error("   ✗ Failed to generate excerpt: #{reason}")
          end
        end)

        Mix.Shell.IO.info("\n✅ Excerpt generation completed!")

      {:error, error} ->
        Mix.Shell.IO.error("Failed to fetch posts: #{inspect(error)}")
    end
  end

  defp generate_excerpt_for_post(slug, preview?) do
    case Post.by_slug(slug) do
      {:ok, post} ->
        case generate_excerpt_with_ai(post) do
          {:ok, excerpt} ->
            if preview? do
              show_excerpt_preview(post, excerpt)
            else
              case Post.update_excerpt(post.id, excerpt) do
                {:ok, _updated_post} ->
                  Mix.Shell.IO.info("✅ Updated excerpt for: #{post.title}")
                  Mix.Shell.IO.info("   Excerpt: \"#{excerpt}\"")

                {:error, changeset} ->
                  Mix.Shell.IO.error("✗ Failed to update excerpt: #{inspect(changeset.errors)}")
              end
            end

          {:error, reason} ->
            Mix.Shell.IO.error("✗ Failed to generate excerpt: #{reason}")
        end

      {:error, _} ->
        Mix.Shell.IO.error("Post not found with slug: #{slug}")
    end
  end

  defp preview_all_excerpts do
    Mix.Shell.IO.info("🔍 Previewing excerpts for all posts...")

    case Post.list_all_posts() do
      {:ok, page} ->
        page.results
        |> Enum.each(fn post ->
          case generate_excerpt_with_ai(post) do
            {:ok, excerpt} ->
              show_excerpt_preview(post, excerpt)

            {:error, reason} ->
              Mix.Shell.IO.error("✗ Failed to generate excerpt for #{post.title}: #{reason}")
          end
        end)

      {:error, error} ->
        Mix.Shell.IO.error("Failed to fetch posts: #{inspect(error)}")
    end
  end

  defp show_excerpt_preview(post, excerpt) do
    Mix.Shell.IO.info("📖 #{post.title}")
    Mix.Shell.IO.info("   Current: \"#{post.excerpt}\"")
    Mix.Shell.IO.info("   Generated: \"#{excerpt}\"")
    Mix.Shell.IO.info("   Length: #{String.length(excerpt)} characters\n")
  end

  defp generate_excerpt_with_ai(post) do
    # Create a combined text for analysis
    combined_text = [
      post.title,
      post.content
    ]
    |> Enum.filter(&(&1 && String.trim(&1) != ""))
    |> Enum.join("\n\n")

    # Try OpenAI first, fall back to simple extraction
    case call_openai_for_excerpt(combined_text) do
      {:ok, excerpt} when is_binary(excerpt) and excerpt != "" ->
        # Clean and validate the excerpt
        cleaned_excerpt =
          excerpt
          |> String.trim()
          |> String.replace(~r/^"|"$/, "") # Remove surrounding quotes
          |> String.slice(0, 200) # Hard limit to 200 characters

        {:ok, cleaned_excerpt}

      {:error, _reason} ->
        # Fallback to simple extraction from content
        simple_excerpt = extract_simple_excerpt(post.content)
        {:ok, simple_excerpt}
    end
  end

  defp call_openai_for_excerpt(content) do
    api_key = System.get_env("OPENAI_API_KEY")

    if is_nil(api_key) or String.trim(api_key) == "" do
      {:error, "OpenAI API key not found"}
    else
      prompt = """
      Please create a concise, engaging excerpt for this blog post that would work well on a blog card.

      Requirements:
      - Maximum 150-180 characters
      - Should be compelling and make readers want to click
      - Focus on the main value/benefit to the reader
      - No quotes around the response
      - Professional but approachable tone

      Blog Post Content:
      #{String.slice(content, 0, 2000)}
      """

      body = %{
        model: "gpt-3.5-turbo",
        messages: [
          %{
            role: "system",
            content: "You are a professional blog editor specializing in creating compelling excerpts for technical blog posts about Elixir, Phoenix, and web development."
          },
          %{role: "user", content: prompt}
        ],
        max_tokens: 100,
        temperature: 0.7
      }

      headers = [
        {"Authorization", "Bearer #{api_key}"},
        {"Content-Type", "application/json"}
      ]

      case Req.post("https://api.openai.com/v1/chat/completions",
                    json: body,
                    headers: headers,
                    receive_timeout: 30_000) do
        {:ok, %{status: 200, body: response}} ->
          case get_in(response, ["choices", Access.at(0), "message", "content"]) do
            excerpt when is_binary(excerpt) ->
              {:ok, String.trim(excerpt)}
            _ ->
              {:error, "Invalid response format"}
          end

        {:ok, %{status: status, body: body}} ->
          Logger.error("OpenAI API error: #{status} - #{inspect(body)}")
          {:error, "API request failed with status #{status}"}

        {:error, error} ->
          Logger.error("OpenAI API request failed: #{inspect(error)}")
          {:error, "Network request failed"}
      end
    end
  end

  defp extract_simple_excerpt(content) when is_binary(content) do
    content
    |> String.replace(~r/\n+/, " ")  # Replace newlines with spaces
    |> String.replace(~r/\s+/, " ")  # Normalize whitespace
    |> String.replace(~r/^#+\s*/, "") # Remove markdown headers
    |> String.trim()
    |> String.slice(0, 150)
    |> then(fn text ->
      # Try to end at a sentence boundary
      case String.split(text, ". ") do
        [first_sentence | _rest] ->
          if String.length(first_sentence) > 50 do
            first_sentence <> "."
          else
            # Find last complete word within limit
            text
            |> String.split(" ")
            |> Enum.reduce_while("", fn word, acc ->
              new_acc = if acc == "", do: word, else: acc <> " " <> word
              if String.length(new_acc) <= 140 do
                {:cont, new_acc}
              else
                {:halt, acc}
              end
            end)
            |> Kernel.<>("...")
          end
        _ ->
          # Find last complete word within limit
          text
          |> String.split(" ")
          |> Enum.reduce_while("", fn word, acc ->
            new_acc = if acc == "", do: word, else: acc <> " " <> word
            if String.length(new_acc) <= 140 do
              {:cont, new_acc}
            else
              {:halt, acc}
            end
          end)
          |> Kernel.<>("...")
      end
    end)
  end

  defp extract_simple_excerpt(_), do: "Learn more about this topic."
end