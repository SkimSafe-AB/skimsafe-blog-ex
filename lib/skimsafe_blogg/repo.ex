defmodule SkimsafeBlogg.Repo do
  use Ecto.Repo,
    otp_app: :skimsafe_blogg,
    adapter: Ecto.Adapters.Postgres
end
