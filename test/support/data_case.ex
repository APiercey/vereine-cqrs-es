defmodule Support.DataCase do
  use ExUnit.CaseTemplate, async: false
  alias :mnesia, as: Mnesia

  alias Read.Applications.Application
  alias Read.Organizations.Organization

  setup do
    [EventStream, Organization, Application]
    |> Enum.map(&Mnesia.clear_table/1)
    |> Enum.all?(fn {:atomic, :ok} -> true end)

    :ok
  end
end
