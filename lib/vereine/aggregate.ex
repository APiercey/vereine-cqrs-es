defmodule Vereine.Aggregate do
  defmacro __using__(opts) do
    projectors = Keyword.get(opts, :projectors, [])

    quote do
      require Logger

      def start_link(id),
        do: GenServer.start_link(__MODULE__, [id, %__MODULE__{id: id}], name: :"#{id}")

      def init([id, data]) do
        with {:ok, pid_tuples} <- start_projectors(id, unquote(projectors)),
             {:ok, _} <- Registry.register(:event_stream, id, []) do
          {:ok, %{data: data, pid_tuples: pid_tuples}}
        else
          err -> {:error, err}
        end
      end

      def start_projectors(id, modules) do
        result =
          Enum.map(modules, fn module ->
            {:ok, pid} = module.start_link(id)
            {module, pid}
          end)

        {:ok, result}
      end

      def generate_id(), do: UUID.uuid4()

      def dispatch(%{id: id} = command) do
        with true <- Vereine.Command.valid?(command),
             %__MODULE__{} = data <- get_aggregate(id),
             {:ok, event} <- execute(data, command),
             {:ok, _pid} <- maybe_start_server(id),
             :ok <- publish_event(id, event) do
          {:ok, event}
        end
      end

      def maybe_start_server(id) do
        case Process.whereis(:"#{id}") do
          nil -> {:ok, _pid} = start_link(id)
          pid -> {:ok, pid}
        end
      end

      def get_aggregate(id) do
        case Process.whereis(:"#{id}") do
          nil ->
            %__MODULE__{}

          _pid ->
            {:ok, %{data: %__MODULE__{} = data}} = get(:"#{id}")
            data
        end
      end

      def get(id), do: GenServer.call(:"#{id}", :get)

      def handle_info({:publish_event, event}, %{data: data} = state) do
        {:noreply, %{state | data: apply_event(data, event)}}
      end

      def handle_call(:get, _from, state),
        do: {:reply, {:ok, state}, state}

      defp publish_event(id, event) do
        Logger.info("Publish event")

        Registry.dispatch(:event_stream, id, fn entries ->
          entries
          |> Enum.map(fn {pid, _} -> pid end)
          |> Enum.map(fn pid -> send(pid, {:publish_event, event}) end)
        end)

        :ok
      end
    end
  end
end
