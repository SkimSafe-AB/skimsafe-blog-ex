defmodule SkimsafeBlogg.Release do
  @moduledoc """
  Used for executing DB release tasks when run in production without Mix
  installed.

  This module provides database migration capabilities for production releases
  where Mix is not available. It includes options for handling SQLite database
  connections safely.
  """
  @app :skimsafe_blogg

  require Logger

  @doc """
  Run database migrations.

  Options:
  - :wait_for_completion - Wait for migrations to complete before returning
  - :timeout - Maximum time to wait for migrations (default: 60 seconds)
  """
  def migrate(opts \\ []) do
    load_app()

    timeout = Keyword.get(opts, :timeout, 60_000)
    wait_for_completion = Keyword.get(opts, :wait_for_completion, true)

    Logger.info("Starting database migrations...")

    task =
      Task.async(fn ->
        for repo <- repos() do
          Logger.info("Running migrations for #{inspect(repo)}...")

          case Ecto.Migrator.with_repo(repo, &run_migrations/1) do
            {:ok, _, migrations} ->
              if Enum.empty?(migrations) do
                Logger.info("No pending migrations for #{inspect(repo)}")
              else
                Logger.info("Completed #{length(migrations)} migrations for #{inspect(repo)}")
              end
              {:ok, repo, migrations}

            {:error, error} ->
              Logger.error("Migration failed for #{inspect(repo)}: #{inspect(error)}")
              {:error, repo, error}
          end
        end
      end)

    if wait_for_completion do
      case Task.await(task, timeout) do
        results when is_list(results) ->
          # Check if any migrations failed
          failures = Enum.filter(results, fn
            {:error, _, _} -> true
            _ -> false
          end)

          if Enum.empty?(failures) do
            Logger.info("All migrations completed successfully")
            :ok
          else
            Logger.error("Some migrations failed: #{inspect(failures)}")
            :error
          end

        error ->
          Logger.error("Migration task failed: #{inspect(error)}")
          :error
      end
    else
      # Return the task for the caller to handle
      task
    end
  rescue
    error ->
      Logger.error("Migration process failed: #{inspect(error)}")
      :error
  end

  @doc """
  Run migrations without blocking.

  Returns a Task that can be awaited or ignored.
  Useful when you want to start the application while migrations run.
  """
  def migrate_async(opts \\ []) do
    opts
    |> Keyword.put(:wait_for_completion, false)
    |> migrate()
  end

  @doc """
  Check if migrations are pending.
  """
  def pending_migrations? do
    load_app()

    repos()
    |> Enum.any?(fn repo ->
      case Ecto.Migrator.with_repo(repo, fn r ->
        migrations_path = Application.app_dir(@app, "priv/repo/migrations")
        pending = Ecto.Migrator.migrations(r, migrations_path)
        Enum.any?(pending, fn {status, _, _} -> status == :down end)
      end) do
        {:ok, _, has_pending} -> has_pending
        _ -> false
      end
    end)
  end

  def rollback(repo, version) do
    load_app()
    Logger.info("Rolling back #{inspect(repo)} to version #{version}")

    case Ecto.Migrator.with_repo(repo, &Ecto.Migrator.run(&1, :down, to: version)) do
      {:ok, _, migrations} ->
        Logger.info("Rollback completed: #{length(migrations)} migrations rolled back")
        :ok

      {:error, error} ->
        Logger.error("Rollback failed: #{inspect(error)}")
        :error
    end
  end

  defp run_migrations(repo) do
    migrations_path = Application.app_dir(@app, "priv/repo/migrations")
    Ecto.Migrator.run(repo, migrations_path, :up, all: true)
  end

  defp repos do
    Application.fetch_env!(@app, :ecto_repos)
  end

  defp load_app do
    Application.load(@app)
  end
end