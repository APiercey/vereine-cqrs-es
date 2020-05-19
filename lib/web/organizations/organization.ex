defmodule Web.Organizations.Organization do
  defstruct [:id, :name, :active]

  def new(attrs \\ %{}) do
    struct(__MODULE__, attrs)
  end

  def change(%__MODULE__{} = organization, attrs) do
    attrs
    |> Map.take([:id, :name])
    |> Map.merge(organization)
    |> new()
  end
end
