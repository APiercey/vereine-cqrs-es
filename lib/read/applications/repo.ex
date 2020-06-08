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
      {:atomic, [{_module, _id, application}]} ->
        application

      {:atomic, []} ->
        {:error, "Application with ID #{id} does not exist"}

      {:aborted, _reason} = error ->
        {:error, error}
    end
  end

  def all do
    fn ->
      Mnesia.match_object({Application, :_, :_})
    end
    |> Mnesia.transaction()
    |> case do
      {:atomic, result} ->
        result |> Enum.map(fn {_module, _id, application} -> application end)

      {:aborted, _reason} = error ->
        {:error, error}
    end
  end

  def store(%Application{id: id} = application) do
    fn ->
      Mnesia.write({Application, id, application})
    end
    |> Mnesia.transaction()
    |> case do
      {:atomic, :ok} -> {:ok, application}
      {:aborted, _reason} = error -> {:error, error}
    end
  end

  def store(_) do
    {:error, :incorrect_format}
  end
end
