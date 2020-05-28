defmodule CQRSComponents.EventStream do
  alias :mnesia, as: Mnesia

  def store_event(aggregate_id, event) do
    with event_id <- generate_event_id(),
         timestamp <- generate_timestamp(),
         :ok <- do_store_event(event_id, aggregate_id, timestamp, event) do
      :ok
    end
  end

  # NOTE: It's not possible for the disributed table to return events
  # in an ordered manner. Consider sorting the events by date after fetching
  def fetch_events_by_aggregate_id(aggregate_id) do
    fn ->
      Mnesia.match_object({EventStream, :_, aggregate_id, :_, :_})
    end
    |> Mnesia.transaction()
    |> case do
      {:atomic, result} ->
        result
        |> Enum.map(fn {_module, _event_id, _aggregate_id, _timestamp, event} -> event end)

      {:aborted, _reason} = error ->
        {:error, error}
    end
  end

  defp generate_event_id(), do: UUID.uuid4()
  defp generate_timestamp(), do: :calendar.universal_time()

  defp do_store_event(event_id, aggregate_id, timestamp, event) do
    fn ->
      Mnesia.write({EventStream, event_id, aggregate_id, timestamp, event})
    end
    |> Mnesia.transaction()
    |> case do
      {:atomic, :ok} -> :ok
      {:aborted, _reason} = error -> {:error, error}
    end
  end
end
