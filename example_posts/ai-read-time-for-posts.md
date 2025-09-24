# Ai-powered mix task that search for and updates posts without read-time

### Usecase
When we write a new md artikel we dont wanna go through it manually to estimate read-time and then manually insert the read-time in the database. Another thing was also that we didnt want just a function that counted the words and gave an estimate, we wanted AI to help us! Even if we use function count_words as a fallback if the api calls fail or the tokens run out.

### Why
The idea for this article also comes from my struggle to find a guide to implement this feuture. This can also be implemented in different contextes, to handle text in a document, like a summary for example. It was also an exploration of writing my own mix tasks to make my life easier and more fun.

### Planning
I already did another custom mix task for applying tags with natural langugage in the md-files, so it wasnt my first even though I consider myself pretty fresh with writing my own custon tasks.

In this article we will:

- AI Integration: OpenAI & Claude APIs for intelligent read time estimation
- Fallback System: Local word-count calculation when APIs are unavailable
- Mix Task: Command-line tool for batch processing posts
- Smart Filtering: Only processes posts without existing read times
- Flexible Usage: Support for dry-run, specific posts, and service selection
- Error Handling: Graceful degradation and proper error reporting
- (Clean Code: Properly formatted, documented, and tested)

#### So what is Elixir Mix tasks?

Think of them as your command-line toolkit getting stuff done in your Elixir projects. Basically Mix tasks are commands you run from the terminal that can handle the heavy-lifting and make else repetive tasks or reoccuring jobs into easy one-line code, like compiling, running tests, spin up documets and whatever else you can imagine you need it for.

Mix is built in and comes with a solid collection of already ready tasks to work with. But when those ready-made tasks dont quite fit what you are trying to do, you can create you own custom tasks.


I started in the config file where I added the config for OpenAI and Claude.

```
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
I copied the api keys from Claude and OpenAi and put it in the .env file.

Then it was time to create a new folder and a new file and write some functions! 

** lib/skimsafe_blogg/ai/read_time_estimator.ex **

This is gonna be a service module thant handles functionality and also creates the prompt and the rules for that.

````
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

In this module I also defined a fallback function that can do wordcount and give an estimate of read-time if the api calls fails or run out of tokens.

The fallback is constructed to it does'nt count the md syntax stuff as words and it exclude the code-blocks to give a more fair read-time.

### Database Helper Module

This wil work with the resource and the repo (database layer) to go through the posts and see if someone misses read-time. If it does a Mix task command will update one or more posts.

#### lib/skimsafe_blogg/blog/post_updater.ex

````
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

  #### lib/mix/tasks/blog.estimate_read_time.ex

  ```
 defmodule Mix.Tasks.Blog.EstimateReadTime do
  use Mix.Task

  alias SkimsafeBlogg.AI.ReadTimeEstimator
  alias SkimsafeBlogg.Blog.PostUpdater

  @shortdoc "Estimate read time for posts using AI services"

  @moduledoc """
  Estimate read time for blog posts using AI/ML services.

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

      IO.puts("\n Run without --dry-run to process these posts")
    else
      Enum.each(posts, &estimate_and_update(&1, service))
      IO.puts("\n Processing complete!")
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
      IO.puts("\n Processing complete!")
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

Now you should be able to run:

	Mix blog.estimate_read_time --dry-run
To check for post without read_time.

    Mix blog.estimate_read_time
To process post without read_time run.


Successfully built a complete AI-powered read time estimation system for your blog!