defmodule SkimsafeBlogg.MarkdownParser do
  @moduledoc """
  Module to parse markdown files with frontmatter and extract post metadata.

  Supports both YAML frontmatter and plain markdown files with H1 headers.
  Used by both the seeding process and the content loader for deployment.

  This is separate from PostRenderer which handles HTML conversion and syntax highlighting.
  MarkdownParser focuses on extracting metadata for database storage.
  """

  @doc """
  Parse a markdown file and extract metadata and content.

  ## Examples

      iex> SkimsafeBlogg.MarkdownParser.parse_file("/path/to/post.md")
      {%{title: "Post Title", tags: ["elixir"]}, "Post content..."}

  Returns a tuple of {metadata_map, content_string}
  """
  def parse_file(file_path) do
    content = File.read!(file_path)

    case String.split(content, "---", parts: 3) do
      ["", frontmatter, markdown_content] ->
        metadata = parse_frontmatter(frontmatter)
        {metadata, String.trim(markdown_content)}

      _ ->
        # No frontmatter, extract title from first H1 and return content
        {title, remaining_content} = extract_title_from_content(content)
        metadata = %{title: title}
        {metadata, String.trim(remaining_content)}
    end
  end

  @doc """
  Extract title from the first H1 header in markdown content.

  Returns {title, remaining_content} tuple.
  """
  def extract_title_from_content(content) do
    lines = String.split(content, "\n")

    case Enum.find_index(lines, &String.starts_with?(&1, "# ")) do
      nil ->
        {"Untitled", content}
      index ->
        title_line = Enum.at(lines, index)
        title = String.trim_leading(title_line, "# ")

        # Remove the title line from content
        remaining_lines = List.delete_at(lines, index)
        remaining_content = Enum.join(remaining_lines, "\n")

        {title, remaining_content}
    end
  end

  @doc """
  Parse YAML-like frontmatter into a metadata map.

  Handles special fields like tags, published, featured, published_at, and read_time_minutes.
  """
  def parse_frontmatter(frontmatter) do
    frontmatter
    |> String.split("\n")
    |> Enum.reduce(%{}, fn line, acc ->
      case String.split(line, ":", parts: 2) do
        [key, value] ->
          key = String.trim(key)
          value = String.trim(value) |> String.trim_leading("\"") |> String.trim_trailing("\"")

          # Parse special fields
          parsed_value = case key do
            "tags" -> parse_tags(value)
            "published" -> value == "true"
            "featured" -> value == "true"
            "published_at" -> parse_datetime(value)
            "read_time_minutes" -> String.to_integer(value)
            _ -> value
          end

          Map.put(acc, String.to_atom(key), parsed_value)

        _ -> acc
      end
    end)
  end

  @doc """
  Parse tags from various formats (array-like or comma-separated).
  """
  def parse_tags(tags_str) do
    case String.trim(tags_str) do
      "[" <> rest ->
        rest
        |> String.trim_trailing("]")
        |> String.split(",")
        |> Enum.map(&String.trim/1)
        |> Enum.map(fn tag -> String.trim(tag, "\"") end)
        |> Enum.reject(&(&1 == ""))

      _ -> []
    end
  end

  @doc """
  Parse datetime strings in various formats.
  """
  def parse_datetime(datetime_str) do
    case DateTime.from_iso8601(datetime_str <> "T00:00:00Z") do
      {:ok, datetime, _} -> datetime
      _ ->
        # Try parsing as date only
        case Date.from_iso8601(datetime_str) do
          {:ok, date} -> DateTime.new!(date, ~T[00:00:00], "Etc/UTC")
          _ -> DateTime.utc_now()
        end
    end
  end

  @doc """
  Create a post attributes map from parsed metadata and content.

  Includes default values and proper data types for database insertion.
  """
  def create_post_attrs(metadata, content, slug) do
    excerpt = metadata[:excerpt] || generate_excerpt_from_content(content)
    featured = metadata[:featured] || determine_featured_status(slug, metadata[:title] || "Untitled")

    %{
      id: Ash.UUID.generate(),
      title: metadata[:title] || "Untitled",
      slug: slug,
      excerpt: excerpt,
      content: content,
      author: metadata[:author] || "SkimSafe Team",
      author_email: metadata[:author_email],
      tags: metadata[:tags] || [],
      featured: featured,
      published: metadata[:published] || true,
      published_at: metadata[:published_at] || DateTime.utc_now(),
      read_time_minutes: metadata[:read_time_minutes] || 5,
      view_count: 0,
      inserted_at: DateTime.utc_now(),
      updated_at: DateTime.utc_now()
    }
  end

  @doc """
  Create slug from filename by replacing underscores and removing extension.
  """
  def filename_to_slug(filename) do
    filename
    |> String.replace(".md", "")
    |> String.replace("_", "-")
  end

  @doc """
  Generate a simple excerpt from content if none provided in metadata.
  """
  def generate_excerpt_from_content(content) when is_binary(content) do
    content
    |> String.replace(~r/\n+/, " ")  # Replace newlines with spaces
    |> String.replace(~r/\s+/, " ")  # Normalize whitespace
    |> String.replace(~r/^#+\s*/, "") # Remove markdown headers
    |> String.replace(~r/\*\*([^*]+)\*\*/, "\\1") # Remove bold formatting
    |> String.replace(~r/\*([^*]+)\*/, "\\1") # Remove italic formatting
    |> String.replace(~r/`([^`]+)`/, "\\1") # Remove inline code formatting
    |> String.replace(~r/\[([^\]]+)\]\([^)]+\)/, "\\1") # Remove links, keep text
    |> String.trim()
    |> String.slice(0, 150)
    |> then(fn text ->
      # Try to end at a sentence boundary
      sentences = String.split(text, ". ")
      case sentences do
        [first_sentence | _rest] ->
          if String.length(first_sentence) > 50 do
            first_sentence <> "."
          else
            create_word_limited_excerpt(text)
          end
        _ ->
          create_word_limited_excerpt(text)
      end
    end)
  end

  def generate_excerpt_from_content(_), do: "Learn more about this topic."

  defp create_word_limited_excerpt(text) do
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

  @doc """
  Determine if a post should be featured based on slug/title.
  """
  def determine_featured_status(slug, title) do
    featured_keywords = [
      "phoenix-installation",
      "elixir-basics",
      "first-phoenix-app",
      "getting-started"
    ]

    slug_downcase = String.downcase(slug)
    title_downcase = String.downcase(title)

    Enum.any?(featured_keywords, fn keyword ->
      String.contains?(slug_downcase, keyword) or String.contains?(title_downcase, keyword)
    end)
  end
end