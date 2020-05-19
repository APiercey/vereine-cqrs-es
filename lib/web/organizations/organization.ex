defmodule Web.Organizations.Organization do
  defstruct id: nil, name: nil, active: 'inactive', can_hire: false, can_aquire_funding: false

  def new(attrs \\ %{}) do
    struct(__MODULE__, attrs)
  end

  def change(%__MODULE__{} = organization, attrs) do
    attrs
    |> Map.take([:id, :name, :can_hire, :can_aquire_funding])
    |> Map.merge(organization)
    |> new()
  end
end
