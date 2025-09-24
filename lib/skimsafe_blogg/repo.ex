defmodule SkimsafeBlogg.Repo do
  use Ecto.Repo,
    otp_app: :skimsafe_blogg,
    adapter: Ecto.Adapters.SQLite3,
    data_layer: AshSqlite.DataLayer

  def installed_extensions do
    # SQLite doesn't use extensions like PostgreSQL
    []
  end

  @doc """
  A callback executed when the repo starts or when configuration is read.
  """
  def init(_type, config) do
    # Enable WAL mode and set optimal pragmas for concurrent access
    {:ok, Keyword.merge(config, [
      pragma: [
        journal_mode: :wal,
        cache_size: 1000,
        temp_store: :memory,
        synchronous: :normal,
        wal_autocheckpoint: 1000
      ]
    ])}
  end
end
