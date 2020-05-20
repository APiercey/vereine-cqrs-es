defmodule Vereine.Projector do
  defmacro __using__(_opts) do
    quote do
      def start_link(id) do
        GenServer.start_link(__MODULE__, id, name: :"#{__MODULE__}_#{id}")
      end

      def init(id) do
        with {:ok, _} = Registry.register(:event_stream, id, []) do
          {:ok, []}
        end
      end

      def handle_info({:publish_event, event}, state) do
        case handle_event(event) do
          :ok -> {:noreply, [state | event]}
        end
      end
    end
  end
end
