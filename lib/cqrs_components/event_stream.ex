defmodule CQRSComponents.EventStream do
  alias :mnesia, as: Mnesia

  alias CQRSComponents.{
    Event,
    StreamCheckpoint
  }

  def store_event(aggregate_id, event_data) do
    {:ok, _event} =
      Event.new(aggregate_id, event_data)
      |> Event.generate_event_id()
      |> Event.generate_timestamp()
      |> do_store_event()
  end

  # NOTE: It's not possible for the disributed table to return events
  # in an ordered manner. Consider sorting the events by date after fetching
  def fetch_events_by_aggregate_id(aggregate_id) do
    fn ->
      Mnesia.match_object({Event, :_, aggregate_id, :_, :_})
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

  def set_stream_checkpoint(process_name, event_id) do
    fn ->
      Mnesia.write({StreamCheckpoint, process_name, event_id})
    end
    |> Mnesia.transaction()
    |> case do
      {:atomic, :ok} -> :ok
      {:aborted, _reason} = error -> {:error, error}
    end
  end

  def get_stream_checkpoint(process_name) do
    fn ->
      Mnesia.match_object({StreamCheckpoint, process_name, :_})
    end
    |> Mnesia.transaction()
    |> case do
      {:atomic, [{_module, _name, event_id}]} ->
        {:ok, event_id}

      {:atomic, []} ->
        {:ok, nil}

      {:aborted, _reason} = error ->
        {:error, error}
    end
  end

  defp do_store_event(
         %Event{event_id: event_id, aggregate_id: aggregate_id, timestamp: timestamp} = event
       ) do
    fn ->
      Mnesia.write({Event, event_id, aggregate_id, timestamp, event})
    end
    |> Mnesia.transaction()
    |> case do
      {:atomic, :ok} -> {:ok, event}
      {:aborted, _reason} = error -> {:error, error}
    end
  end
end
