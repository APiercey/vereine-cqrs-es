defmodule Mix.Tasks.Db.Migrate do
  @shortdoc """
  Migrate an :mnesia datastore
  """
  use Mix.Task

  alias :mnesia, as: Mnesia
  alias Organizations.Organization
  require Logger

  @impl Mix.Task

  def run(_) do
    with :ok = Mnesia.start(),
         :ok = migrate() do
      Logger.info("Database migrated successfully")
    end
  end

  defp migrate do
    with :ok <- create_event_stream(),
         :ok <- create_organization() do
      :ok
    end
  end

  defp create_event_stream do
    case Mnesia.create_table(EventStream, attributes: [:event_id, :aggegate_id, :timestamp, :data]) do
      {:atomic, :ok} -> :ok
      {:aborted, {:already_exists, EventStream}} -> :ok
    end
  end

  defp create_organization do
    case Mnesia.create_table(Organization, attributes: [:id, :data]) do
      {:atomic, :ok} -> :ok
      {:aborted, {:already_exists, Organization}} -> :ok
    end
  end
end
