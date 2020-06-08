defmodule Support.Helpers.Database do
  alias :mnesia, as: Mnesia

  alias Read.Applications.Application
  alias Read.Organizations.Organization

  alias CQRSComponents.{
    Event,
    StreamCheckpoint
  }

  def clear_database do
    {:atomic, :ok} = Mnesia.clear_table(Organization)
    {:atomic, :ok} = Mnesia.clear_table(Application)
    {:atomic, :ok} = Mnesia.clear_table(Event)
    {:atomic, :ok} = Mnesia.clear_table(StreamCheckpoint)

    :ok
  end
end
