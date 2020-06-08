defmodule Mix.Tasks.Db.Migrate do
  @shortdoc """
  Migrate an :mnesia datastore
  """
  use Mix.Task

  alias :mnesia, as: Mnesia

  alias Read.Applications.Application
  alias Read.Organizations.Organization

  alias CQRSComponents.{
    Event,
    StreamCheckpoint
  }

  require Logger

  @impl Mix.Task

  def run(_) do
    with :ok <- Mnesia.start(),
         :ok <- migrate() do
      Logger.info("Database migrated successfully")
    end
  end

  defp migrate do
    with :ok <- create_event(),
         :ok <- create_stream_checkpoint(),
         :ok <- create_application(),
         :ok <- create_organization() do
      :ok
    end
  end

  defp create_event do
    case Mnesia.create_table(Event, attributes: [:event_id, :aggegate_id, :timestamp, :data]) do
      {:atomic, :ok} -> :ok
      {:aborted, {:already_exists, Event}} -> :ok
    end
  end

  defp create_stream_checkpoint do
    case Mnesia.create_table(StreamCheckpoint,
           attributes: [:process_name, :event_id]
         ) do
      {:atomic, :ok} -> :ok
      {:aborted, {:already_exists, StreamCheckpoint}} -> :ok
    end
  end

  defp create_application do
    case Mnesia.create_table(Application, attributes: [:id, :data]) do
      {:atomic, :ok} -> :ok
      {:aborted, {:already_exists, Organization}} -> :ok
    end
  end

  defp create_organization do
    case Mnesia.create_table(Organization, attributes: [:id, :data]) do
      {:atomic, :ok} -> :ok
      {:aborted, {:already_exists, Organization}} -> :ok
    end
  end
end
