defmodule SkimsafeBlogg.Repo do
  use Ecto.Repo,
    otp_app: :skimsafe_blogg,
    adapter: Ecto.Adapters.SQLite3,
    data_layer: AshSqlite.DataLayer

  def installed_extensions do
    # SQLite doesn't use extensions like PostgreSQL
    []
  end
end
