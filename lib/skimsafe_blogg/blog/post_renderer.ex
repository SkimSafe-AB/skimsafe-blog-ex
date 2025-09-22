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
    # Use NimblePublisher's highlighting capabilities
    markdown_content
    |> Earmark.as_html!(
      code_class_prefix: "language-",
      smartypants: false
    )
    |> NimblePublisher.highlight(highlighters: [:makeup_elixir, :makeup_erlang])
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
end
