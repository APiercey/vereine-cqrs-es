defmodule CQRSComponents.Event do
  defstruct [:event_id, :aggregate_id, :timestamp, :event]

  def new(aggregate_id, %{} = event) do
    %__MODULE__{aggregate_id: aggregate_id, event: event}
  end

  def generate_timestamp(%__MODULE__{} = event),
    do: %{event | timestamp: :calendar.universal_time()}

  def generate_event_id(%__MODULE__{} = event), do: %{event | event_id: UUID.uuid4()}
end
