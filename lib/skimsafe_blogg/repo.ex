defmodule SkimsafeBlogg.Repo do
  use Ecto.Repo,
    otp_app: :skimsafe_blogg,
    adapter: Ecto.Adapters.SQLite3,
    data_layer: AshSqlite.DataLayer
end
