defmodule SkimsafeBlogg.Blog.PostRenderer do
  @moduledoc """
  Renders markdown content to HTML with syntax highlighting using NimblePublisher.
  This module provides a hybrid approach - using Ash for database operations
  and NimblePublisher for HTML rendering.
  """

  @doc """
  Converts markdown content to HTML with syntax highlighting.
  """
  def render_content(markdown_content) when is_binary(markdown_content) do
    # Convert markdown to HTML first
    html =
      Earmark.as_html!(markdown_content,
        code_class_prefix: "language-",
        smartypants: false
      )

    # Apply syntax highlighting to code blocks
    highlight_code_blocks(html)
  end

  def render_content(_), do: ""

  @doc """
  Processes a database post to include rendered HTML content.
  """
  def process_post(post) do
    rendered_content = render_content(post.content)
    Map.put(post, :rendered_content, rendered_content)
  end

  @doc """
  Processes multiple posts to include rendered HTML content.
  """
  def process_posts(posts) when is_list(posts) do
    Enum.map(posts, &process_post/1)
  end

  # Private functions

  defp highlight_code_blocks(html) do
    # Use regex to find and replace code blocks with highlighted versions
    Regex.replace(
      ~r/<code class="([^"]+) language-([^"]+)">(.*?)<\/code>/s,
      html,
      fn _, _class, language, code ->
        highlighted_code = highlight_code(code, language)

        # Check if the highlighted code already has pre/code tags
        if String.contains?(highlighted_code, "<pre class=\"highlight\">") do
          # Extract the content from the inner pre/code tags
          inner_content =
            Regex.replace(
              ~r/<pre class="highlight"><code>(.*?)<\/code><\/pre>/s,
              highlighted_code,
              fn _, content -> content end
            )

          ~s(<code class="makeup #{language}">#{inner_content}</code>)
        else
          ~s(<code class="makeup #{language}">#{highlighted_code}</code>)
        end
      end
    )
  end

  defp highlight_code(code, "elixir") do
    try do
      Makeup.highlight(code, lexer: Makeup.Lexers.ElixirLexer)
    rescue
      _ -> code |> Phoenix.HTML.html_escape() |> Phoenix.HTML.safe_to_string()
    end
  end

  defp highlight_code(code, "erlang") do
    try do
      Makeup.highlight(code, lexer: Makeup.Lexers.ErlangLexer)
    rescue
      _ -> code |> Phoenix.HTML.html_escape() |> Phoenix.HTML.safe_to_string()
    end
  end

  defp highlight_code(code, _language) do
    # For unsupported languages, just escape HTML
    code |> Phoenix.HTML.html_escape() |> Phoenix.HTML.safe_to_string()
  end
end
