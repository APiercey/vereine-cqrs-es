defmodule Vereine.Aggregate do
  defmacro __using__(opts) do
    projectors = Keyword.get(opts, :projectors, [])

    quote do
      require Logger

      def start_link(id),
        do: GenServer.start_link(__MODULE__, [id, %__MODULE__{id: id}], name: :"#{id}")

      def init([id, data]) do
        with {:ok, pid_tuples} <- start_projectors(id, unquote(projectors)) do
          {:ok, %{data: data, pid_tuples: pid_tuples}}
        else
          err -> {:error, err}
        end
      end

      def get(id), do: GenServer.call(:"#{id}", :get)

      def dispatch(%{id: id} = command) do
        with true <- Vereine.Command.valid?(command),
             {:ok, _pid} <- maybe_start_server(id),
             {:ok, event} <- GenServer.call(:"#{id}", {:execute_command, command}),
             :ok <- publish_event(id, event) do
          {:ok, id}
        end
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
          nil -> {:ok, _pid} = start_link(id)
          pid -> {:ok, pid}
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
