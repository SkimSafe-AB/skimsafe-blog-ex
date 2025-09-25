# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     SkimsafeBlogg.Repo.insert!(%SkimsafeBlogg.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

alias SkimsafeBlogg.Repo

# Module to parse markdown files with frontmatter
defmodule MarkdownParser do
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

  defp extract_title_from_content(content) do
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

  defp parse_frontmatter(frontmatter) do
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

  defp parse_tags(tags_str) do
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

  defp parse_datetime(datetime_str) do
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
end

# Clear existing posts
IO.puts("Clearing existing posts...")
Repo.delete_all("posts")

# Load all markdown files from priv/content
content_dir = Path.join([Application.app_dir(:skimsafe_blogg), "priv", "content"])

if File.exists?(content_dir) do
  content_dir
  |> File.ls!()
  |> Enum.filter(&String.ends_with?(&1, ".md"))
  |> Enum.each(fn filename ->
    file_path = Path.join(content_dir, filename)
    IO.puts("Processing #{filename}...")

    {metadata, content} = MarkdownParser.parse_file(file_path)

    # Create slug from filename
    slug = filename |> String.replace(".md", "") |> String.replace("_", "-")

    # Create post struct
    post_attrs = %{
      id: Ash.UUID.generate(),
      title: metadata[:title] || "Untitled",
      slug: slug,
      excerpt: metadata[:excerpt] || "",
      content: content,
      author: metadata[:author] || "SkimSafe Team",
      author_email: metadata[:author_email],
      tags: metadata[:tags] || [],
      featured: metadata[:featured] || false,
      published: metadata[:published] || true,
      published_at: metadata[:published_at] || DateTime.utc_now(),
      read_time_minutes: metadata[:read_time_minutes] || 5,
      view_count: 0,
      inserted_at: DateTime.utc_now(),
      updated_at: DateTime.utc_now()
    }

    # Insert into database using raw SQL since we're not using Ecto schemas
    Repo.query!("""
      INSERT INTO posts (
        id, title, slug, excerpt, content, author, author_email,
        tags, featured, published, published_at, read_time_minutes,
        view_count, inserted_at, updated_at
      ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
    """, [
      post_attrs.id,
      post_attrs.title,
      post_attrs.slug,
      post_attrs.excerpt,
      post_attrs.content,
      post_attrs.author,
      post_attrs.author_email,
      Jason.encode!(post_attrs.tags),
      post_attrs.featured,
      post_attrs.published,
      post_attrs.published_at,
      post_attrs.read_time_minutes,
      post_attrs.view_count,
      post_attrs.inserted_at,
      post_attrs.updated_at
    ])

    IO.puts("✅ Created post: #{post_attrs.title}")
  end)

  IO.puts("\n🎉 Database seeding completed successfully!")
else
  IO.puts("❌ Content directory not found: #{content_dir}")
end