defmodule SkimsafeBlogg.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      SkimsafeBloggWeb.Telemetry,
      SkimsafeBlogg.Repo,
      {DNSCluster, query: Application.get_env(:skimsafe_blogg, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: SkimsafeBlogg.PubSub},
      # ContentLoader - loads blog posts from markdown files on startup
      SkimsafeBlogg.ContentLoader,
      # Start a worker by calling: SkimsafeBlogg.Worker.start_link(arg)
      # {SkimsafeBlogg.Worker, arg},
      # Start to serve requests, typically the last entry
      SkimsafeBloggWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: SkimsafeBlogg.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    SkimsafeBloggWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
