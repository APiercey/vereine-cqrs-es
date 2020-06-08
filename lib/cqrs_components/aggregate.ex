defmodule CQRSComponents.Aggregate do
  defmacro __using__(opts) do
    projectors = Keyword.get(opts, :projectors, [])

    quote do
      require Logger

      def start_link(id),
        do: GenServer.start_link(__MODULE__, [id, %__MODULE__{id: id}], name: :"#{id}")

      def init([id, init_state]) do
        with state <- build_state(id, init_state),
             {:ok, pid_tuples} <- start_projectors(id, unquote(projectors)) do
          {:ok, %{data: state, pid_tuples: pid_tuples}}
        else
          err -> {:error, err}
        end
      end

      def get(id) do
        case Process.whereis(:"#{id}") do
          nil -> {:error, "The aggregate is not alive with id #{id}"}
          _ -> GenServer.call(:"#{id}", :get)
        end
      end

      def dispatch(%{id: id} = command) do
        with {:valid, true} <- {:valid, CQRSComponents.Command.valid?(command)},
             {:ok, _pid} <- maybe_start_server(id),
             {:ok, aggregate_event} <- GenServer.call(:"#{id}", {:execute_command, command}),
             {:ok, event} <- CQRSComponents.EventStream.store_event(id, aggregate_event),
             :ok <- publish_event(id, event) do
          {:ok, id}
        else
          {:valid, false} -> {:error, "Command was invalid"}
        end
      end

      defp build_state(id, data) do
        id
        |> CQRSComponents.EventStream.fetch_events_by_aggregate_id()
        |> Enum.map(fn %CQRSComponents.Event{event: event} -> event end)
        |> Enum.reduce(data, &apply_event(&2, &1))
      end

      defp start_projectors(id, modules) do
        result =
          Enum.map(modules, fn module ->
            {:ok, pid} = module.start_link(id)
            {module, pid}
          end)

        {:ok, result}
      end

      defp maybe_start_server(id) do
        case Process.whereis(:"#{id}") do
          nil ->
            {:ok, _pid} =
              DynamicSupervisor.start_child(CQRSComponents.AggregateSupervisor, {__MODULE__, id})

          pid ->
            {:ok, pid}
        end
      end

      def handle_call({:execute_command, command}, _from, %{data: data} = state) do
        case execute(data, command) do
          {:error, _} = error ->
            {:reply, error, state}

          {:ok, event} ->
            {:reply, {:ok, event}, %{state | data: apply_event(data, event)}}
        end
      end

      def handle_call(:get, _from, state),
        do: {:reply, {:ok, state}, state}

      defp publish_event(id, event) do
        Registry.dispatch(:event_stream, id, fn entries ->
          entries
          |> Enum.map(fn {pid, _} -> pid end)
          |> Enum.map(fn pid -> send(pid, {:publish_event, event}) end)
        end)

        :ok
      end

      def child_spec(opts) do
        %{
          id: __MODULE__,
          start: {__MODULE__, :start_link, [opts]},
          type: :worker,
          restart: :permanent,
          shutdown: 500
        }
      end
    end
  end
end
