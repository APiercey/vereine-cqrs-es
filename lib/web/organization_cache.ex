defmodule Web.OrganizationCache do
  use Agent

  alias Vereine.Events.ApplicationAccepted

  def start_link(_) do
    Agent.start_link(fn -> %{} end, name: __MODULE__)
  end

  def get(id) do
    Agent.get(__MODULE__, fn state -> Map.get(state, :"#{id}", nil) end)
  end

  def apply(%ApplicationAccepted{id: id}) do
    Agent.update(
      __MODULE__,
      fn state ->
        deep_merge(state, %{"#{id}": %{active: true}})
      end
    )
  end

  def apply(_event) do

  end

  defp deep_merge(left, right) do
    Map.merge(left, right, &deep_resolve/3)
  end

  # Key exists in both maps, and both values are maps as well.
  # These can be merged recursively.
  defp deep_resolve(_key, left = %{}, right = %{}) do
    deep_merge(left, right)
  end

  # Key exists in both maps, but at least one of the values is
  # NOT a map. We fall back to standard merge behavior, preferring
  # the value on the right.
  defp deep_resolve(_key, _left, right) do
    right
  end
end
