defmodule Vereine.CommandRouter do
  alias Vereine.Aggregates.Organization

  alias Vereine.Commands.{
    Application,
    CreateOrganization
  }

  def route(%CreateOrganization{} = command), do: Organization.dispatch(command)
end
