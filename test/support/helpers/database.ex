defmodule Support.Helpers.Database do
  alias :mnesia, as: Mnesia

  alias Read.Applications.Application
  alias Read.Organizations.Organization

  def clear_database do
    {:atomic, :ok} = Mnesia.clear_table(EventStream)
    {:atomic, :ok} = Mnesia.clear_table(Organization)
    {:atomic, :ok} = Mnesia.clear_table(Application)

    :ok
  end
end
