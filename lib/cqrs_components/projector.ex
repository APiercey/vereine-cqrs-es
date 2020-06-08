defmodule CQRSComponents.Projector do
  defmacro __using__(_opts) do
    quote do
      alias CQRSComponents.{
        Event,
        EventStream
      }

      def start_link(id) do
        name = process_name(id)

        GenServer.start_link(__MODULE__, [id, name], name: name)
      end

      def process_name(id), do: :"#{__MODULE__}_#{id}"

      def init([aggregate_id, name]) do
        with {:ok, _} <- Registry.register(:event_stream, aggregate_id, []),
             {:ok, event_id} <- EventStream.get_stream_checkpoint(name) do
          state = %{name: name, checkpoint: event_id, aggregate_id: aggregate_id}
          {:ok, state, {:continue, :process_events}}
        end
      end

      def handle_continue(:process_events, %{aggregate_id: aggegate_id, name: name} = state) do
        pid = name |> Process.whereis()

        aggegate_id
        |> EventStream.fetch_events_by_aggregate_id()
        |> Enum.each(fn event -> send(pid, {:publish_event, event}) end)

        {:noreply, state}
      end

      def handle_info(
            {:publish_event, %Event{event: event, event_id: event_id}},
            %{name: name} = state
          ) do
        with :ok <- process_event(event),
             :ok <- EventStream.set_stream_checkpoint(name, event_id) do
          {:noreply, %{state | checkpoint: event_id}}
        end
      end

      def get(id) do
        case Process.whereis(:"#{__MODULE__}_#{id}") do
          nil -> {:error, "The projector is not alive with id #{id}"}
          _ -> GenServer.call(:"#{__MODULE__}_#{id}", :get)
        end
      end

      def handle_call(:get, _from, state),
        do: {:reply, {:ok, state}, state}

      defp process_event(event) do
        case handle_event(event) do
          {:dispatch, command} ->
            route_command(command)
            :ok

          :ok ->
            :ok

          unexpected ->
            {:error, :unexpected, unexpected}
        end
      end

      defp route_command(command) do
        with router <- Application.fetch_env!(:vereine, :command_router) do
          router.route(command)
        end
      end
    end
  end
end
