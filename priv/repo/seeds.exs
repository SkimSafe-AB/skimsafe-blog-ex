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

alias SkimsafeBlogg.{Repo, MarkdownParser}

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
    slug = MarkdownParser.filename_to_slug(filename)

    # Create post struct using shared parser
    post_attrs = MarkdownParser.create_post_attrs(metadata, content, slug)

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