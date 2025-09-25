# AI-powered Mix Task that Searches for and Updates Posts without "Read-Time"

When we write a new markdown article, we don't want to go through it manually to estimate read time and then manually insert that read time into the database, right? And to write a function that counted words and gave an estimate seems so 2024... Let´s implement some AI to help us! But we will use a word_count function as a fallback if the API calls fail or we run out of tokens.

The idea for this article came from my struggle to find a guide for implementing this feature. This can also be implemented in different contexts to handle text in documents, like generating summaries, for example. 
It was also an exploration of writing my own Mix tasks to make my life easier and more fun.

I'd already built another custom Mix task for applying tags with natural language in the markdown files, so this wasn't my first rodeo with mix tasks even though I still consider myself pretty fresh with writing custom tasks.

In this article we'll cover the implememtation of:

- **AI Integration**: OpenAI & Claude APIs for intelligent read time estimation
- **Fallback System**: Local word-count calculation when APIs are unavailable
- **Mix Task**: Command-line tool for batch processing posts
- **Smart Filtering**: Only processes posts without existing read times
- **Flexible Usage**: Support for dry-run, specific posts, and service selection
- **Error Handling**: Nice degradation and proper error reporting

Tech-stack for this app is: Ash and Phoenix with Sqlite3 database

#### So what are Elixir Mix tasks?

Think of them as your command-line toolkit for getting stuff done in your Elixir projects. Basically, Mix tasks are commands you run from the terminal that handle the heavy lifting and turn repetitive tasks or recurring jobs into easy one-liners, like compiling, running tests, spinning up documentation, and whatever else you can imagine needing.

Mix is built-in and comes with a solid collection of ready-to-use tasks. But when those ready-made tasks don't quite fit what you're trying to do, you can create your own custom tasks.

I started in the config file where I added the configuration for OpenAI and Claude:

```elixir
config :skimsafe_blogg, :ai_services,
  openai: [
    api_key: System.get_env("OPENAI_API_KEY"),
    model: "gpt-3.5-turbo",
    base_url: "https://api.openai.com/v1"
  ],
  claude: [
    api_key: System.get_env("ANTHROPIC_API_KEY"),
    base_url: "https://api.anthropic.com/v1"
  ]
```

This config block is pretty straightforward but super important! We're telling our app where to find the API credentials (from environment variables - never hardcode your secrets, folks!) and setting up the base URLs for both services. The OpenAI model is set to GPT-3.5-turbo because it's fast and cheap for this kind of simple task.

I copied the API keys from Claude and OpenAI and put them in the `.env` file.

Then it was time to create a new folder and file and write some functions!

### AI Service Module

This is going to be a service module that handles the functionality and also creates the prompts and rules:

**lib/skimsafe_blogg/ai/read_time_estimator.ex**

```elixir
defmodule SkimsafeBlogg.AI.ReadTimeEstimator do
  @moduledoc "AI-powered read time estimation service"

  def estimate_read_time(content, service \\ :openai) do
    case service do
      :openai -> call_openai(content)
      :claude -> call_claude(content)
      :local_ml -> call_local_model(content)
    end
  end

  defp call_openai(content) do
    config = Application.get_env(:skimsafe_blogg, :ai_services)[:openai]

    prompt = """
    Analyze this blog post content and estimate reading time in minutes.
    Consider technical complexity, code blocks, and typical reading patterns.
    Return only the number of minutes as an integer.
    
    Content:
    #{String.slice(content, 0, 4000)}
    """

    body = %{
      model: config[:model],
      messages: [%{role: "user", content: prompt}],
      max_tokens: 10,
      temperature: 0.1
    }

    case Req.post(
      url: "#{config[:base_url]}/chat/completions",
      headers: [
        {"Authorization", "Bearer #{config[:api_key]}"},
        {"Content-Type", "application/json"}
      ],
      json: body
    ) do
      {:ok, %{status: 200, body: %{"choices" => [%{"message" => %{"content" => response}}]}}} ->
        parse_minutes(response)

      {:error, _} ->
        fallback_calculation(content)
    end
  end

  defp call_claude(content) do
    # Similar implementation for Claude API
    config = Application.get_env(:skimsafe_blogg, :ai_services)[:claude]
    # Implementation details...
    fallback_calculation(content) # For now
  end

  defp call_local_model(content) do
    # Local ML model or simple calculation
    fallback_calculation(content)
  end

  defp parse_minutes(response) do
    case Integer.parse(String.trim(response)) do
      {minutes, _} when minutes > 0 -> minutes
      _ -> fallback_calculation("")
    end
  end

  defp fallback_calculation(content) do
    word_count =
      content
      |> String.replace(~r/```[\s\S]*?```/, " ")
      |> String.replace(~r/#+ /, "")
      |> String.replace(~r/[*_`\[\]()#-]/, "")
      |> String.split()
      |> length()

    max(1, round(word_count / 225))
  end
end
```

Alright, let's break down what's happening in this module because there's some stuff going on here!

The `estimate_read_time/2` function is our main entry point. It takes the content and an optional service parameter (defaulting to `:openai`). This pattern matching approach makes it super easy to swap between different AI services or even add new ones later.

Now, the `call_openai/1` function is where the magic happens! First, it grabs our config that we set up earlier. Then it builds a really specific prompt - notice how I'm telling the AI exactly what I want: "Return only the number of minutes as an integer." This is crucial because we need predictable output that we can parse easily.

The `String.slice(content, 0, 4000)` part is important too - we're limiting the content to 4000 characters to avoid hitting token limits and keep costs down. For most blog posts, the first 4000 characters give the AI enough context to make a good estimate.

A simple example to explain how it works is:
Full post: 8000 characters
  - Sample analyzed: first 4000 characters
  - AI finds: Heavy technical content with code blocks
  - AI estimates: "This type of content = ~150 WPM instead of 200 WPM"
  - Final estimate: 8000 chars ≈ 1600 words ≈ 11 minutes at 150 WPM

The API call itself uses `Req.post` (which is the HTTP client). The `max_tokens: 10` setting keeps it cheap since we only need a single number back, and `temperature: 0.1` makes the response more deterministic - we don't want creative variations in our read time estimates!

The pattern matching in the `case` statement is classic Elixir goodness. We're looking for a successful 200 response with the expected JSON structure. If anything goes wrong - network issues, API errors, whatever - we fall back to our local calculation.

The `parse_minutes/1` function is doing some defensive parsing. `Integer.parse/1` returns a tuple like `{42, ""}` if successful, or `:error` if it can't parse the string. The guard `when minutes > 0` ensures we get a sensible result - nobody wants a 0-minute read time!

And here's where the `fallback_calculation/1` function gets interesting! This isn't just a simple word count, it's doing:

```elixir
content
|> String.replace(~r/```[\s\S]*?```/, " ")  # Remove code blocks
|> String.replace(~r/#+ /, "")              # Remove markdown headers  
|> String.replace(~r/[*_`\[\]()#-]/, "")    # Remove markdown syntax
|> String.split()                           # Split into words
|> length()                                 # Count them
```

The first regex `~r/```[\s\S]*?```/` removes entire code blocks because people don't read code at the same speed as regular text. The `[\s\S]*?` part matches any character (including newlines) in a non-greedy way - this ensures we capture the whole code block without going too far.

Then we strip out markdown headers (`#+ `) and other syntax characters that aren't really "words" for reading purposes. Finally, we divide by 225 words per minute, which is a pretty standard reading speed, and use `max(1, ...)` to ensure every post gets at least 1 minute.

### Database Helper Module

This will work with the resource and the repo (database layer) to go through the posts and see if any are missing read times. If they are, a Mix task command will update one or more posts.

**lib/skimsafe_blogg/blog/post_updater.ex**

```elixir
defmodule SkimsafeBlogg.Blog.PostUpdater do
  alias SkimsafeBlogg.Resources.Post
  alias SkimsafeBlogg.Repo

  def get_posts_without_read_time do
    Post.list_all_posts!()
    |> Enum.filter(fn post ->
      is_nil(post.read_time_minutes) or post.read_time_minutes == 0
    end)
  end

  def get_posts_by_ids(post_ids) do
    # Convert string IDs to proper format and fetch posts
    Post.list_all_posts!()
    |> Enum.filter(fn post ->
      Enum.any?(post_ids, &(&1 == to_string(post.id) or &1 == post.slug))
    end)
  end

  def update_post_read_time(post_id, minutes) do
    # Direct SQLite update since we're using Ash
    query = "UPDATE posts SET read_time_minutes = ? WHERE id = ?"
    Ecto.Adapters.SQL.query!(Repo, query, [minutes, post_id])
  end
end
```

This module is our database interface, and it's doing some clever filtering work.

The `get_posts_without_read_time/0` function is straightforward but effective. It grabs all posts and then filters for ones where `read_time_minutes` is either `nil` or `0`. The `is_nil/1` check catches posts that were created before we added the read_time field, while the `== 0` catches any that might have been explicitly set to zero.

`get_posts_by_ids/1` is more interesting because it handles both numeric IDs and slugs! The `Enum.any?/2` with that funky `&(&1 == to_string(post.id) or &1 == post.slug)` syntax is checking if any of the provided identifiers match either the stringified post ID or the slug. This makes the Mix task super flexible - you can run it with `mix blog.estimate_read_time 123` or `mix blog.estimate_read_time my-awesome-post-slug`.

The `update_post_read_time/2` function uses raw SQL because I'm using Ash framework, which sometimes makes direct updates a bit tricky. The `Ecto.Adapters.SQL.query!/3` function lets us run raw SQL safely with parameter binding (those `?` placeholders prevent SQL injection attacks).

### The Mix Task

**lib/mix/tasks/blog.estimate_read_time.ex**

```elixir
defmodule Mix.Tasks.Blog.EstimateReadTime do
  use Mix.Task

  alias SkimsafeBlogg.AI.ReadTimeEstimator
  alias SkimsafeBlogg.Blog.PostUpdater

  @shortdoc "Estimate read time for posts using AI services"

  @moduledoc """
  Estimate read time for blog posts using AI/ML services.
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
    IO.puts("Finding posts without read time...")

    posts = PostUpdater.get_posts_without_read_time()
    IO.puts("Found #{length(posts)} posts to process")

    if dry_run do
      Enum.each(posts, fn post ->
        IO.puts("  - #{post.title} (#{post.slug})")
      end)

      IO.puts("Run without --dry-run to process these posts")
    else
      Enum.each(posts, &estimate_and_update(&1, service))
      IO.puts("Processing complete!")
    end
  end

  defp process_specific_posts(identifiers, service, dry_run) do
    IO.puts("Processing specific posts: #{Enum.join(identifiers, ", ")}")

    posts = PostUpdater.get_posts_by_ids(identifiers)

    if dry_run do
      Enum.each(posts, fn post ->
        IO.puts("  - #{post.title} (current: #{post.read_time_minutes || "none"})")
      end)
    else
      Enum.each(posts, &estimate_and_update(&1, service))
      IO.puts("Processing complete!")
    end
  end

  defp estimate_and_update(post, service) do
    IO.puts("Processing: #{post.title}")
    IO.puts("Service: #{service}")

    estimated_minutes = ReadTimeEstimator.estimate_read_time(post.content, service)

    PostUpdater.update_post_read_time(post.id, estimated_minutes)

    IO.puts("Estimated: #{estimated_minutes} minutes")
  rescue
    error ->
      IO.puts("Error: #{inspect(error)}")
  end
end
```

This is where everything comes together! Mix tasks need to `use Mix.Task` and implement a `run/1` function that takes command-line arguments.

The `Mix.Task.run("app.start")` line is crucial - it starts up our entire application so we can access the database and all our modules. Without this, the task would run in isolation.

The `OptionParser.parse/2` is doing some heavy lifting here. It's parsing command-line arguments into a nice tuple: `{opts, post_identifiers, _}`. The `switches` option tells it what flags to expect (`--service` and `--dry-run`), and `aliases` lets us use short versions (`-s` and `-d`).

The pattern matching on `post_identifiers` works like this:
- If the list is empty (`[]`), we process all posts without read times
- If there are identifiers, we process just those specific posts

The `dry_run` functionality is handy for testing. When enabled, it just shows you what would be processed without actually making any changes. This has saved me from accidentally processing hundreds of posts when I just wanted to test something.

The `estimate_and_update/2` function is where the actual work happens. It calls our AI service, updates the database, and provides nice console output so you can see the progress. The `rescue` clause catches any errors and prints them out instead of crashing the whole task - because nobody wants to lose progress halfway through processing a bunch of posts!

That `&estimate_and_update(&1, service)` syntax is Elixir's capture operator - it's a shorthand for `fn post -> estimate_and_update(post, service) end`. Super clean!

### Usage

Now you should be able to run:

```bash
mix blog.estimate_read_time --dry-run
```
To check for posts without read time. This will show you exactly what posts would be processed without actually changing anything.

```bash
mix blog.estimate_read_time
```
To process all posts without read time using OpenAI (the default service).

```bash
mix blog.estimate_read_time --service claude
```
To use Claude instead of OpenAI for the estimates.

```bash
mix blog.estimate_read_time my-post-slug another-post --service claude --dry-run
```
To see what would happen if you processed specific posts with Claude.

And that's it! You've successfully built a complete AI-powered read time estimation system for your blog. Pretty nice how Mix tasks can automate these kinds of repetitive workflows! The best part is how modular everything is - you can easily swap AI services, modify the fallback calculation, or even add completely new features like content summarization using the same patterns.

In the future I wanna build our own ML model and train it on the posts. 
Elixir has Axon that would be a great way to start!

Louise Blanc