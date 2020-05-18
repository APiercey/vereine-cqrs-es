defmodule Vereine.Commands.AddFeature do
  defstruct [:id, :feature]
end

defimpl Vereine.Command, for: Vereine.Commands.AddFeature do
  def valid?(command) do
    [&has_id/1, &has_feature/1]
    |> Enum.map(fn fun -> fun.(command) end)
    |> Enum.all?()
  end

  defp has_id(%{id: nil}), do: false
  defp has_id(_), do: true
  defp has_feature(%{feature: feature}), do: [:employeer, :fundable] |> Enum.member?(feature)
end
