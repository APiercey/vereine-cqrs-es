defmodule Vereine.Projecters.ApplicationFinalization do
  use CQRSComponents.Projector

  alias Vereine.Events.ApplicationAccepted
  alias Vereine.Commands.CreateOrganization

  def handle_event(%ApplicationAccepted{id: id}) do
    command =
      %{application_id: id}
      |> CreateOrganization.new()
      |> CreateOrganization.add_id()

    {:dispatch, command}
  end

  def handle_event(_), do: :ok
end
