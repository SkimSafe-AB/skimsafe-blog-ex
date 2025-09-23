defmodule SkimsafeBlogg.AI.ReadTimeEstimator do
  @moduledoc "AI-based read time estimator for blog posts."

  def estimate_read_time(content, service \\ :openai) do
    case service do
      :openai -> call_openai(content)
      :claude -> call_claude(content)
      :local_ml -> call_local_model(content)
      _ -> fallback_calculation(content)
    end
  end

  defp call_openai(content) do
    config = Application.get_env(:skimsafe_blogg, :ai_services)[:openai]

    if is_nil(config) or is_nil(config[:api_key]) do
      fallback_calculation(content)
    else
      prompt = """
      Analyze the following blog post content and estimate the read time in minutes.
      Consider technical complexity, code blocks, and typical reading patterns.
      Return only the number of minutes as an integer.
      Content:
      #{String.slice(content, 0, 4000)}
      """

      body = %{
        model: config[:model] || "gpt-3.5-turbo",
        messages: [%{role: "user", content: prompt}],
        max_tokens: 10,
        temperature: 0.1
      }

      case Req.post(
             url: "#{config[:base_url] || "https://api.openai.com/v1"}/chat/completions",
             headers: [
               {"Authorization", "Bearer #{config[:api_key]}"},
               {"Content-Type", "application/json"}
             ],
             json: body
           ) do
        {:ok,
         %{status: 200, body: %{"choices" => [%{"message" => %{"content" => response}} | _]}}} ->
          parse_minutes(response)

        {:error, error} ->
          IO.puts("OpenAI API Error: #{inspect(error)}")
          fallback_calculation(content)

        {:ok, %{status: status, body: body}} ->
          IO.puts("OpenAI API returned status: #{status}")
          IO.puts("Response body: #{inspect(body)}")
          fallback_calculation(content)
      end
    end
  end

  defp call_claude(content) do
    config = Application.get_env(:skimsafe_blogg, :ai_services)[:claude]

    if is_nil(config) or is_nil(config[:api_key]) do
      fallback_calculation(content)
    else
      prompt = """
      Analyze the following blog post content and estimate the read time in minutes.
      Consider technical complexity, code blocks, and typical reading patterns.
      Return only the number of minutes as an integer.
      Content:
      #{String.slice(content, 0, 4000)}
      """

      body = %{
        model: config[:model] || "claude-3-haiku-20240307",
        max_tokens: 10,
        messages: [%{role: "user", content: prompt}]
      }

      case Req.post(
             url: "#{config[:base_url] || "https://api.anthropic.com/v1"}/messages",
             headers: [
               {"x-api-key", config[:api_key]},
               {"Content-Type", "application/json"},
               {"anthropic-version", "2023-06-01"}
             ],
             json: body
           ) do
        {:ok, %{status: 200, body: %{"content" => [%{"text" => response}]}}} ->
          parse_minutes(response)

        {:error, error} ->
          IO.puts("Claude API Error: #{inspect(error)}")
          fallback_calculation(content)

        {:ok, %{status: status, body: body}} ->
          IO.puts("Claude API returned status: #{status}")
          IO.puts("Response body: #{inspect(body)}")
          fallback_calculation(content)
      end
    end
  end

  defp call_local_model(content) do
    fallback_calculation(content)
  end

  defp parse_minutes(response) do
    response
    |> String.trim()
    |> String.replace(~r/[^\d]/, "")
    |> case do
      "" ->
        1

      digits ->
        case Integer.parse(digits) do
          {minutes, _} when minutes > 0 and minutes <= 60 -> minutes
          _ -> 1
        end
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
