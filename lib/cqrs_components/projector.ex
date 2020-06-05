defmodule CQRSComponents.Projector do
  defmacro __using__(_opts) do
    quote do
      def start_link(id) do
        GenServer.start_link(__MODULE__, id, name: :"#{__MODULE__}_#{id}")
      end

      def init(id) do
        with {:ok, _} <- Registry.register(:event_stream, id, []) do
          {:ok, []}
        end
      end

      def handle_info({:publish_event, event}, state) do
        case handle_event(event) do
          {:dispatch, command} ->
            route_command(command)

          :ok ->
            nil
        end

        {:noreply, state ++ [event]}
      end

      def get(id) do
        case Process.whereis(:"#{__MODULE__}_#{id}") do
          nil -> {:error, "The projector is not alive with id #{id}"}
          _ -> GenServer.call(:"#{__MODULE__}_#{id}", :get)
        end
      end

      def handle_call(:get, _from, state),
        do: {:reply, {:ok, state}, state}

      defp route_command(command) do
        with router <- Application.fetch_env!(:vereine, :command_router) do
          router.route(command)
        end
      end
    end
  end
end
