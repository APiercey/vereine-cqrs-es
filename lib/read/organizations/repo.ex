defmodule Read.Organizations.Repo do
  alias :mnesia, as: Mnesia
  alias Read.Organizations.Organization

  def one(nil), do: {:error, "nil is not a valid ID"}

  def one(id) do
    fn ->
      Mnesia.match_object({Organization, id, :_})
    end
    |> Mnesia.transaction()
    |> case do
      {:atomic, [{_module, _id, organization}]} ->
        organization

      {:aborted, _reason} = error ->
        {:error, error}
    end
  end

  def all() do
    fn ->
      Mnesia.match_object({Organization, :_, :_})
    end
    |> Mnesia.transaction()
    |> case do
      {:atomic, result} ->
        result |> Enum.map(fn {_module, _id, organization} -> organization end)

      {:aborted, _reason} = error ->
        {:error, error}
    end
  end

  def store(%Organization{id: id} = organization) do
    fn ->
      Mnesia.write({Organization, id, organization})
    end
    |> Mnesia.transaction()
    |> case do
      {:atomic, :ok} -> {:ok, organization}
      {:aborted, _reason} = error -> {:error, error}
    end
  end

  def store(_), do: {:error, :incorrect_format}
end
