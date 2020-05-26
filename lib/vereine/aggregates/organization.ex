defmodule Vereine.Aggregates.Organization do
  defstruct [:id, :status, :name]

  alias Vereine.Commands.{
    SubmitApplication,
    FinalizeApplication,
    AddFeature
  }

  alias Vereine.Events.{
    ApplicationSubmitted,
    ApplicationAccepted,
    ApplicationRejected,
    FeatureAdded
  }

  alias Vereine.Projecters.{
    UpdateWeb
  }

  use Vereine.Aggregate, projectors: [UpdateWeb]

  def generate_id(), do: UUID.uuid4()

  def execute(%__MODULE__{status: nil}, %SubmitApplication{id: id, name: name}),
    do: {:ok, %ApplicationSubmitted{id: id, name: name}}

  def execute(%__MODULE__{status: 'open'}, %SubmitApplication{}),
    do: {:error, "Application already submitted"}

  def execute(%__MODULE__{}, %SubmitApplication{}),
    do: {:error, "Sorry, this application cannot be changed"}

  def execute(%__MODULE__{status: 'open', name: nil, id: id}, %FinalizeApplication{}),
    do: {:ok, %ApplicationRejected{id: id}}

  def execute(%__MODULE__{status: 'open', id: id}, %FinalizeApplication{}),
    do: {:ok, %ApplicationAccepted{id: id}}

  def execute(%__MODULE__{}, %FinalizeApplication{}),
    do: {:error, "This application is already finalized"}

  def execute(%__MODULE__{status: 'open'}, %AddFeature{id: id} = command),
    do: {:ok, %FeatureAdded{id: id, feature: command.feature}}

  def execute(%__MODULE__{}, %AddFeature{}),
    do: {:error, "Sorry, a feature cannot be added to this application"}

  def execute(%__MODULE__{}, _command), do: {:error, "Command not processed"}

  def apply_event(%__MODULE__{} = state, %ApplicationAccepted{}),
    do: %{state | status: 'accepted'}

  def apply_event(%__MODULE__{} = state, %ApplicationRejected{}),
    do: %{state | status: 'rejected'}

  def apply_event(%__MODULE__{} = state, %ApplicationSubmitted{name: name}),
    do: %{state | status: 'open', name: name}

  def apply_event(state, event) do
    Logger.info("Event not support for #{event.__struct__}")
    state
  end
end
