defmodule Read.Applications.Repo do
  alias :mnesia, as: Mnesia
  alias Read.Applications.Application

  def one(nil), do: {:error, "nil is not a valid ID"}

  def one(id) do
    fn ->
      Mnesia.match_object({Application, id, :_})
    end
    |> Mnesia.transaction()
    |> case do
      {:atomic, [{_module, _id, Application}]} ->
        Application

      {:aborted, _reason} = error ->
        {:error, error}
    end
  end

  def all() do
    fn ->
      Mnesia.match_object({Application, :_, :_})
    end
    |> Mnesia.transaction()
    |> case do
      {:atomic, result} ->
        result |> Enum.map(fn {_module, _id, Application} -> Application end)

      {:aborted, _reason} = error ->
        {:error, error}
    end
  end

  def store(%Application{id: id} = Application) do
    fn ->
      Mnesia.write({Application, id, Application})
    end
    |> Mnesia.transaction()
    |> case do
      {:atomic, :ok} -> {:ok, Application}
      {:aborted, _reason} = error -> {:error, error}
    end
  end

  def store(_), do: {:error, :incorrect_format}
end
