defmodule Fakes.FakeCommand do
  defstruct [:id, :message]
end

defimpl Vereine.Command, for: Fakes.FakeCommand do
  def valid?(message: nil), do: false
  def valid?(_), do: true
end
