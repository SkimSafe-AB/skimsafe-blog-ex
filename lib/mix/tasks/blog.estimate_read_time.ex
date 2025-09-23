defmodule Mix.Tasks.Blog.EstimateReadTime do
  use Mix.Task

  alias SkimsafeBlogg.AI.ReadTimeEstimator
  alias SkimsafeBlogg.Blog.PostUpdater

  @shortdoc "Estimate read time for posts using AI services"

  @moduledoc """
  Estimate read time for blog posts using AI/ML services.

  ## Usage:

      # Process all posts without read time
      mix blog.estimate_read_time

      # Process specific posts by ID or slug
      mix blog.estimate_read_time post-slug-1 post-slug-2

      # Use different AI service
      mix blog.estimate_read_time --service=claude

      # Dry run to see what would be processed
      mix blog.estimate_read_time --dry-run
  """

  def run(args) do
    Mix.Task.run("app.start")

    {opts, post_identifiers, _} =
      OptionParser.parse(args,
        switches: [service: :string, dry_run: :boolean],
        aliases: [s: :service, d: :dry_run]
      )

    service = String.to_atom(opts[:service] || "openai")
    dry_run = opts[:dry_run] || false

    case post_identifiers do
      [] ->
        process_posts_without_read_time(service, dry_run)

      identifiers ->
        process_specific_posts(identifiers, service, dry_run)
    end
  end

  defp process_posts_without_read_time(service, dry_run) do
    IO.puts("🔍 Finding posts without read time...")

    posts = PostUpdater.get_posts_without_read_time()
    IO.puts("📝 Found #{length(posts)} posts to process")

    if dry_run do
      Enum.each(posts, fn post ->
        IO.puts("  - #{post.title} (#{post.slug})")
      end)

      IO.puts("\n🎯 Run without --dry-run to process these posts")
    else
      Enum.each(posts, &estimate_and_update(&1, service))
      IO.puts("\n✅ Processing complete!")
    end
  end

  defp process_specific_posts(identifiers, service, dry_run) do
    IO.puts("🎯 Processing specific posts: #{Enum.join(identifiers, ", ")}")

    posts = PostUpdater.get_posts_by_ids(identifiers)

    if dry_run do
      Enum.each(posts, fn post ->
        IO.puts("  - #{post.title} (current: #{post.read_time_minutes || "none"})")
      end)
    else
      Enum.each(posts, &estimate_and_update(&1, service))
      IO.puts("\n✅ Processing complete!")
    end
  end

  defp estimate_and_update(post, service) do
    IO.puts("📖 Processing: #{post.title}")
    IO.puts("   Service: #{service}")

    estimated_minutes = ReadTimeEstimator.estimate_read_time(post.content, service)

    PostUpdater.update_post_read_time(post.id, estimated_minutes)

    IO.puts("   ✅ Estimated: #{estimated_minutes} minutes")
  rescue
    error ->
      IO.puts("   ❌ Error: #{inspect(error)}")
  end
end