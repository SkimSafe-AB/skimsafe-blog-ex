defmodule SkimsafeBlogg.AutoTagger do
  @moduledoc """
  Service for automatically generating tags for blog posts using natural language processing.

  Focuses on Elixir, Phoenix, LiveView, Ash, web development, and cybersecurity topics.
  """

  require Logger

  @predefined_tags %{
    # Elixir ecosystem
    "elixir" => ["Elixir"],
    "phoenix" => ["Phoenix", "Elixir"],
    "liveview" => ["LiveView", "Phoenix"],
    "livebook" => ["Livebook", "Elixir"],
    "nerves" => ["Nerves", "Elixir", "IoT"],
    "broadway" => ["Broadway", "Elixir"],
    "genserver" => ["GenServer", "Elixir", "OTP"],
    "supervisor" => ["Supervisor", "Elixir", "OTP"],
    "otp" => ["OTP", "Elixir"],
    "beam" => ["BEAM", "Elixir"],
    "erlang" => ["Erlang", "BEAM"],
    "ecto" => ["Ecto", "Elixir", "Database"],
    "plug" => ["Plug", "Elixir"],
    "cowboy" => ["Cowboy", "Elixir"],

    # Ash Framework
    "ash" => ["Ash", "Elixir"],
    "ash framework" => ["Ash", "Elixir"],
    "ash_postgres" => ["AshPostgres", "Ash", "PostgreSQL"],
    "ash_sqlite" => ["AshSqlite", "Ash", "SQLite"],
    "ash_phoenix" => ["AshPhoenix", "Ash", "Phoenix"],
    "ash_graphql" => ["AshGraphql", "Ash", "GraphQL"],
    "ash_json_api" => ["AshJsonApi", "Ash", "JSON API"],
    "resource" => ["Ash Resources", "Ash"],
    "domain" => ["Ash Domains", "Ash"],

    # Phoenix specific
    "phoenix liveview" => ["LiveView", "Phoenix"],
    "livecomponent" => ["LiveComponent", "LiveView"],
    "phoenix pubsub" => ["PubSub", "Phoenix", "Real-time"],
    "channels" => ["Phoenix Channels", "Phoenix", "Real-time"],
    "presence" => ["Phoenix Presence", "Phoenix", "Real-time"],
    "heex" => ["HEEx", "Phoenix", "Templates"],
    "surface" => ["Surface", "Phoenix", "LiveView"],

    # Web development
    "html" => ["HTML", "Web Development"],
    "css" => ["CSS", "Web Development"],
    "javascript" => ["JavaScript", "Web Development"],
    "tailwind" => ["Tailwind CSS", "CSS"],
    "alpine" => ["Alpine.js", "JavaScript"],
    "websocket" => ["WebSockets", "Real-time"],
    "rest" => ["REST API", "API"],
    "graphql" => ["GraphQL", "API"],
    "json api" => ["JSON API", "API"],
    "api" => ["API", "Web Development"],
    "spa" => ["SPA", "Web Development"],
    "pwa" => ["PWA", "Web Development"],
    "responsive" => ["Responsive Design", "CSS"],
    "accessibility" => ["Accessibility", "Web Development"],

    # Database and data
    "postgresql" => ["PostgreSQL", "Database"],
    "sqlite" => ["SQLite", "Database"],
    "database" => ["Database"],
    "sql" => ["SQL", "Database"],
    "migration" => ["Database Migration", "Database"],
    "schema" => ["Database Schema", "Database"],
    "query" => ["Database Query", "Database"],

    # Cybersecurity
    "security" => ["Security", "Cybersecurity"],
    "cybersecurity" => ["Cybersecurity"],
    "authentication" => ["Authentication", "Security"],
    "authorization" => ["Authorization", "Security"],
    "csrf" => ["CSRF", "Security"],
    "xss" => ["XSS", "Security"],
    "sql injection" => ["SQL Injection", "Security"],
    "encryption" => ["Encryption", "Security"],
    "hashing" => ["Hashing", "Security"],
    "oauth" => ["OAuth", "Authentication"],
    "jwt" => ["JWT", "Authentication"],
    "session" => ["Session Management", "Security"],
    "cors" => ["CORS", "Security"],
    "https" => ["HTTPS", "Security"],
    "tls" => ["TLS", "Security"],
    "ssl" => ["SSL", "Security"],
    "vulnerability" => ["Vulnerability", "Security"],
    "penetration testing" => ["Penetration Testing", "Security"],
    "threat modeling" => ["Threat Modeling", "Security"],
    "secure coding" => ["Secure Coding", "Security"],
    "privacy" => ["Privacy", "Security"],
    "gdpr" => ["GDPR", "Privacy"],
    "compliance" => ["Compliance", "Security"],

    # Development practices
    "testing" => ["Testing"],
    "unit testing" => ["Unit Testing", "Testing"],
    "integration testing" => ["Integration Testing", "Testing"],
    "property testing" => ["Property Testing", "Testing", "Elixir"],
    "exunit" => ["ExUnit", "Testing", "Elixir"],
    "test driven development" => ["TDD", "Testing"],
    "tdd" => ["TDD", "Testing"],
    "behavior driven development" => ["BDD", "Testing"],
    "bdd" => ["BDD", "Testing"],
    "continuous integration" => ["CI/CD", "DevOps"],
    "deployment" => ["Deployment", "DevOps"],
    "docker" => ["Docker", "DevOps"],
    "release" => ["Elixir Release", "Deployment"],
    "distillery" => ["Distillery", "Elixir", "Deployment"],

    # Performance and monitoring
    "performance" => ["Performance"],
    "telemetry" => ["Telemetry", "Elixir", "Monitoring"],
    "monitoring" => ["Monitoring"],
    "logging" => ["Logging"],
    "metrics" => ["Metrics", "Monitoring"],
    "observability" => ["Observability", "Monitoring"],
    "load testing" => ["Load Testing", "Performance"],
    "benchmarking" => ["Benchmarking", "Performance"],
    "caching" => ["Caching", "Performance"],

    # Patterns and architecture
    "microservices" => ["Microservices", "Architecture"],
    "distributed systems" => ["Distributed Systems", "Architecture"],
    "event sourcing" => ["Event Sourcing", "Architecture"],
    "cqrs" => ["CQRS", "Architecture"],
    "actor model" => ["Actor Model", "Elixir"],
    "pub sub" => ["Pub/Sub", "Architecture"],
    "real-time" => ["Real-time"],
    "concurrent" => ["Concurrency", "Elixir"],
    "fault tolerance" => ["Fault Tolerance", "Elixir"],

    # Content types
    "tutorial" => ["Tutorial"],
    "guide" => ["Guide"],
    "getting started" => ["Getting Started", "Tutorial"],
    "best practices" => ["Best Practices"],
    "tips" => ["Tips"],
    "beginner" => ["Beginner"],
    "intermediate" => ["Intermediate"],
    "advanced" => ["Advanced"],
    "case study" => ["Case Study"],
    "example" => ["Example"]
  }

  @doc """
  Generate tags for a post using keyword-based analysis.
  """
  def generate_tags_from_content(content) when is_binary(content) do
    content
    |> String.downcase()
    |> extract_keywords()
    |> Enum.flat_map(&keyword_to_tags/1)
    |> Enum.uniq()
    # Limit to 8 tags maximum
    |> Enum.take(8)
  end

  def generate_tags_from_content(_), do: []

  @doc """
  Generate tags for a post using all available text (title + excerpt + content).
  """
  def generate_tags_for_post(%{title: title, excerpt: excerpt, content: content}) do
    combined_text =
      [title, excerpt, content]
      |> Enum.reject(&is_nil/1)
      |> Enum.join(" ")

    generate_tags_from_content(combined_text)
  end

  def generate_tags_for_post(%{title: title, content: content}) do
    combined_text =
      [title, content]
      |> Enum.reject(&is_nil/1)
      |> Enum.join(" ")

    generate_tags_from_content(combined_text)
  end

  def generate_tags_for_post(_), do: []

  @doc """
  Generate tags using OpenAI API for more sophisticated analysis.
  Requires OPENAI_API_KEY environment variable to be set.
  """
  def generate_tags_with_ai(content, opts \\ []) do
    api_key = System.get_env("OPENAI_API_KEY")

    if is_nil(api_key) do
      Logger.info("OpenAI API key not configured, falling back to keyword-based tagging")
      generate_tags_from_content(content)
    else
      case call_openai_api(content, api_key, opts) do
        {:ok, tags} ->
          tags

        {:error, reason} ->
          Logger.warning(
            "OpenAI API call failed: #{inspect(reason)}, falling back to keyword-based tagging"
          )

          generate_tags_from_content(content)
      end
    end
  end

  @doc """
  Update tags for a specific post.
  """
  def auto_tag_post(%{id: post_id} = post) do
    new_tags = generate_tags_for_post(post)

    case SkimsafeBlogg.Resources.Post.update_tags(post_id, new_tags) do
      {:ok, updated_post} ->
        Logger.info("Successfully updated tags for post #{post_id}: #{inspect(new_tags)}")
        {:ok, updated_post}

      {:error, changeset} ->
        Logger.error("Failed to update tags for post #{post_id}: #{inspect(changeset)}")
        {:error, changeset}
    end
  end

  @doc """
  Auto-tag all published posts in the system.
  """
  def auto_tag_all_posts do
    case SkimsafeBlogg.Resources.Post.list_published() do
      {:ok, posts} ->
        results = Enum.map(posts, &auto_tag_post/1)

        successful = Enum.count(results, fn {status, _} -> status == :ok end)
        failed = Enum.count(results, fn {status, _} -> status == :error end)

        Logger.info("Auto-tagging completed: #{successful} successful, #{failed} failed")
        {:ok, %{successful: successful, failed: failed, results: results}}

      {:error, reason} ->
        Logger.error("Failed to list published posts: #{inspect(reason)}")
        {:error, reason}
    end
  end

  # Private functions

  defp extract_keywords(text) do
    text
    |> String.split(~r/\W+/, trim: true)
    |> Enum.reject(&(String.length(&1) < 3))
    |> extract_phrases(text)
    |> Enum.uniq()
  end

  defp extract_phrases(words, text) do
    # Extract multi-word phrases
    phrases =
      @predefined_tags
      |> Map.keys()
      |> Enum.filter(&String.contains?(text, &1))

    # Combine single words and phrases
    words ++ phrases
  end

  defp keyword_to_tags(keyword) do
    Map.get(@predefined_tags, keyword, [])
  end

  defp call_openai_api(content, api_key, opts) do
    max_tokens = Keyword.get(opts, :max_tokens, 100)
    model = Keyword.get(opts, :model, "gpt-3.5-turbo")

    prompt = """
    Please analyze the following blog post content and generate relevant tags.
    Focus ONLY on: Elixir, Phoenix, LiveView, Ash Framework, web development, and cybersecurity topics.
    Return only a JSON array of strings, with each tag being 1-3 words maximum.
    Limit to 8 tags maximum.

    Content:
    #{String.slice(content, 0, 3000)}
    """

    body = %{
      model: model,
      messages: [
        %{
          role: "system",
          content:
            "You are a technical blog content analyzer specializing in Elixir, Phoenix, LiveView, Ash Framework, web development, and cybersecurity. Return only JSON arrays of tags."
        },
        %{role: "user", content: prompt}
      ],
      max_tokens: max_tokens,
      temperature: 0.3
    }

    case Req.post("https://api.openai.com/v1/chat/completions",
           headers: [
             {"Authorization", "Bearer #{api_key}"},
             {"Content-Type", "application/json"}
           ],
           json: body
         ) do
      {:ok, %{status: 200, body: %{"choices" => [%{"message" => %{"content" => content}}]}}} ->
        parse_ai_response(content)

      {:ok, %{status: status, body: body}} ->
        {:error, "OpenAI API returned status #{status}: #{inspect(body)}"}

      {:error, reason} ->
        {:error, "HTTP request failed: #{inspect(reason)}"}
    end
  end

  defp parse_ai_response(content) do
    case Jason.decode(String.trim(content)) do
      {:ok, tags} when is_list(tags) ->
        validated_tags =
          tags
          |> Enum.filter(&is_binary/1)
          |> Enum.map(&String.trim/1)
          |> Enum.reject(&(&1 == ""))
          |> Enum.take(8)

        {:ok, validated_tags}

      {:error, _} ->
        {:error, "Failed to parse JSON response from OpenAI"}
    end
  end
end
