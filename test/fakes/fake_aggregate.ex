defmodule Fakes.FakeAggregate do
  defstruct [:id, :message]

  use Vereine.Aggregate

  alias Fakes.{
    FakeCommand,
    FakeEvent
  }

  def execute(%__MODULE__{id: id}, %FakeCommand{message: message}),
    do: {:ok, %FakeEvent{id: id, message: message}}

  def apply_event(%__MODULE__{} = state, %FakeEvent{message: message}),
    do: %{state | message: message}
end
