defmodule Read.Organizations.Organization do
  defstruct id: nil, name: nil, application_id: nil

  def new(attrs \\ %{}), do: struct(__MODULE__, attrs)

  def change(%__MODULE__{} = organization, attrs) do
    change_set = Map.take(attrs, [:id, :status, :name, :can_hire, :can_aquire_funding])

    organization
    |> Map.from_struct()
    |> Map.merge(change_set)
    |> new()
  end
end
