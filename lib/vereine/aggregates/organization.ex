defmodule Vereine.Aggregates.Organization do
  defstruct [:id, :status, :application_id]

  require Logger

  alias Vereine.Commands.CreateOrganization
  alias Vereine.Events.OrganizationCreated
  alias Vereine.Projecters.UpdateRead

  use CQRSComponents.Aggregate, projectors: [UpdateRead]

  def execute(%__MODULE__{status: nil}, %CreateOrganization{
        id: id,
        application_id: application_id
      }),
      do: {:ok, %OrganizationCreated{id: id, application_id: application_id}}

  def execute(%__MODULE__{}, _command), do: {:error, "Command not processed"}

  def apply_event(%__MODULE__{} = state, %OrganizationCreated{
        id: id,
        application_id: application_id
      }) do
    %{state | id: id, application_id: application_id, status: 'created'}
  end

  def apply_event(state, event) do
    Logger.info("Event not support for #{event.__struct__}")
    state
  end
end
