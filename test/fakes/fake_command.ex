defmodule Fakes.FakeCommand do
  defstruct [:id, :message]
end

defimpl CQRSComponents.Command, for: Fakes.FakeCommand do
  def valid?(message: nil), do: false
  def valid?(_), do: true
end
