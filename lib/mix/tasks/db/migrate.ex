defmodule Mix.Tasks.Db.Migrate do
  @shortdoc """
  Migrate an :mnesia datastore
  """
  use Mix.Task

  alias :mnesia, as: Mnesia
  alias Web.Organizations.Organization
  require Logger

  @impl Mix.Task

  def run(_) do
    with :ok = Mnesia.start(),
         :ok = migrate() do
      Logger.info("Database migrated successfully")
    end
  end

  defp migrate do
    case Mnesia.create_table(Organization, attributes: [:id, :data]) do
      {:atomic, :ok} -> :ok
      {:aborted, {:already_exists, Organization}} -> :ok
    end
  end
end
