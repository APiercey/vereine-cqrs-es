defmodule Vereine.Projector do
  defmacro __using__(_opts) do
    quote do
      def start_link(id) do
        GenServer.start_link(__MODULE__, id, name: :"#{id}")
      end

      def init(id) do
        with {:ok, _} = Registry.register(:event_stream, id, []) do
          {:ok, []}
        end
      end

      def handle_info({:publish_event, event}, state) do
        case handle_event(event) do
          :ok -> {:noreply, state ++ [event]}
        end
      end

      def get(id) do
        case Process.whereis(:"#{id}") do
          nil -> {:error, "The projector is not alive with id #{id}"}
          _ -> GenServer.call(:"#{id}", :get)
        end
      end

      def handle_call(:get, _from, state),
        do: {:reply, {:ok, state}, state}
    end
  end
end
