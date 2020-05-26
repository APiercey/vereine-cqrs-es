defmodule Vereine.Commands.SubmitApplication do
  defstruct [:id, :name]
end

defimpl CQRSComponents.Command, for: Vereine.Commands.SubmitApplication do
  def valid?(command) do
    [&has_id/1]
    |> Enum.map(fn fun -> fun.(command) end)
    |> Enum.all?()
  end

  defp has_id(%{id: nil}), do: false
  defp has_id(_), do: true
end
