defmodule Web.Organizations.Repo do
  alias :mnesia, as: Mnesia
  alias Web.Organizations.Organization

  def one(nil),
    do: {:error, "nil is not a valid ID"}

  def one(id) do
    fn ->
      Mnesia.match_object({Organization, id, :_})
    end
    |> Mnesia.transaction()
    |> case do
      {:atomic, result} -> result |> record_to_organization()
      {:aborted, reason} = error -> {:error, error}
    end
  end

  def all() do
    fn ->
      Mnesia.match_object({Organization, :_, :_})
    end
    |> Mnesia.transaction()
    |> case do
      {:atomic, result} ->
        result |> Enum.map(&record_to_organization/1)

      {:aborted, reason} = error ->
        {:error, error}
    end
  end

  def insert(%Organization{id: id} = organization) do
    fn ->
      Mnesia.write({Organization, id, organization})
    end
    |> Mnesia.transaction()
    |> case do
      {:atomic, :ok} -> {:ok, organization}
      {:aborted, reason} = error -> {:error, error}
    end
  end

  def insert(_), do: {:error, :incorrect_format}

  defp record_to_organization({Organization, _id, data}),
    do: Organization.new(data)
end
