defmodule Vereine.Commands.SubmitApplication do
  defstruct [:id, :name]

  def new(attrs), do: struct(__MODULE__, attrs)
  def add_id(%__MODULE__{id: nil} = command), do: %{command | id: UUID.uuid4()}
end

defimpl CQRSComponents.Command, for: Vereine.Commands.SubmitApplication do
  def valid?(command) do
    [&has_id/1, &has_name/1]
    |> Enum.map(fn fun -> fun.(command) end)
    |> Enum.all?()
  end

  defp has_id(%{id: nil}), do: false
  defp has_id(_), do: true
  defp has_name(%{name: nil}), do: false
  defp has_name(_), do: true
end
