defmodule Mix.Tasks.Db.Migrate do
  @moduledoc """
  Run database migrations for SkimSafe Blog.

  This task runs database migrations using the same connection pool as the application,
  preventing SQLite database locking issues that can occur when migrations run
  concurrently with the application startup.

  ## Examples

      # Run all pending migrations
      mix db.migrate

      # Run migrations up to a specific version
      mix db.migrate --to 20250919140443

      # Show migration status
      mix db.migrate --status
  """

  use Mix.Task
  require Logger

  alias SkimsafeBlogg.Repo

  @shortdoc "Run database migrations for SkimSafe Blog"

  def run(args) do
    # Start the application to ensure repo is available
    Mix.Task.run("app.start")

    {opts, _args, _invalid} =
      OptionParser.parse(args,
        switches: [
          to: :integer,
          status: :boolean,
          help: :boolean
        ],
        aliases: [
          t: :to,
          s: :status,
          h: :help
        ]
      )

    cond do
      opts[:help] ->
        show_help()

      opts[:status] ->
        show_migration_status()

      opts[:to] ->
        migrate_to_version(opts[:to])

      true ->
        migrate_all()
    end
  end

  defp migrate_all do
    Logger.info("Running all pending migrations...")

    case Ecto.Migrator.run(Repo, migrations_path(), :up, all: true) do
      [] ->
        Mix.Shell.IO.info("No pending migrations found.")

      migrations ->
        Enum.each(migrations, fn
          {:ok, version, name} ->
            Mix.Shell.IO.info("✓ #{version} - #{name}")

          {:error, version, error} ->
            Mix.Shell.IO.error("✗ #{version} - #{inspect(error)}")
        end)

        Mix.Shell.IO.info("Migration completed!")
    end
  rescue
    error ->
      Mix.Shell.IO.error("Migration failed: #{inspect(error)}")
      System.halt(1)
  end

  defp migrate_to_version(version) do
    Logger.info("Running migrations up to version #{version}...")

    case Ecto.Migrator.run(Repo, migrations_path(), :up, to: version) do
      [] ->
        Mix.Shell.IO.info("No migrations to run up to version #{version}.")

      migrations ->
        Enum.each(migrations, fn
          {:ok, v, name} ->
            Mix.Shell.IO.info("✓ #{v} - #{name}")

          {:error, v, error} ->
            Mix.Shell.IO.error("✗ #{v} - #{inspect(error)}")
        end)

        Mix.Shell.IO.info("Migration to version #{version} completed!")
    end
  rescue
    error ->
      Mix.Shell.IO.error("Migration failed: #{inspect(error)}")
      System.halt(1)
  end

  defp show_migration_status do
    Logger.info("Checking migration status...")

    with_repo(fn ->
      repo_status = Ecto.Migrator.migrations(Repo, migrations_path())

      Mix.Shell.IO.info("\nMigration status:")
      Mix.Shell.IO.info("================")

      if Enum.empty?(repo_status) do
        Mix.Shell.IO.info("No migrations found.")
      else
        Enum.each(repo_status, fn {status, version, description} ->
          status_symbol = if status == :up, do: "✓", else: "✗"
          status_text = String.upcase(to_string(status))
          Mix.Shell.IO.info("#{status_symbol} #{version} - #{status_text} - #{description}")
        end)
      end
    end)
  end

  defp with_repo(fun) do
    # Ensure the repo is started
    Repo.start_link()
    fun.()
  rescue
    error ->
      Mix.Shell.IO.error("Database connection failed: #{inspect(error)}")
      System.halt(1)
  end

  defp migrations_path do
    Application.app_dir(:skimsafe_blogg, "priv/repo/migrations")
  end

  defp show_help do
    Mix.Shell.IO.info("""
    Run database migrations for SkimSafe Blog

    ## Usage

        mix db.migrate [options]

    ## Options

        --to, -t      Run migrations up to a specific version
        --status, -s  Show migration status without running migrations
        --help, -h    Show this help message

    ## Examples

        # Run all pending migrations
        mix db.migrate

        # Run migrations up to a specific version
        mix db.migrate --to 20250919140443

        # Check migration status
        mix db.migrate --status

    ## Notes

    This task uses the same database connection pool as your running application,
    preventing SQLite database locking issues that can occur with concurrent access.

    For production deployments, you may want to run migrations before starting
    the application server to ensure a clean startup process.
    """)
  end
end