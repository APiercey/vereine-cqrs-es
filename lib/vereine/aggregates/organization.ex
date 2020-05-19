defmodule Vereine.Aggregates.Organization do
  use GenServer
  require Logger

  defstruct [:id, :status, :name]

  alias Vereine.Commands.{
    SubmitApplication,
    FinalizeApplication,
    AddFeature
  }

  alias Vereine.Events.{
    ApplicationSubmitted,
    ApplicationAccepted,
    ApplicationRejected,
    FeatureAdded
  }

  alias Vereine.Projecters.{
    UpdateCache
  }

  def start_link(id),
    do: GenServer.start_link(__MODULE__, [id, %__MODULE__{id: id}], name: :"#{id}")

  def init([id, data]) do
    with {:ok, update_cache_pid} <- UpdateCache.start_link(id),
         {:ok, _} = Registry.register(:event_stream, id, []) do
      {:ok, %{data: data, update_cache_pid: update_cache_pid}}
    else
      err -> {:error, err}
    end
  end

  def generate_id(), do: UUID.uuid4()

  def execute(%__MODULE__{id: nil}, %SubmitApplication{id: id, name: name}) do
    {:ok, %ApplicationSubmitted{id: id, name: name}}
  end

  def execute(%__MODULE__{status: 'open', name: nil, id: id}, %FinalizeApplication{}) do
    {:ok, %ApplicationRejected{id: id}}
  end

  def execute(%__MODULE__{status: 'open', id: id}, %FinalizeApplication{}) do
    {:ok, %ApplicationAccepted{id: id}}
  end

  def execute(%__MODULE__{status: 'open'}, %AddFeature{id: id} = command) do
    {:ok, %FeatureAdded{id: id, feature: command.feature}}
  end

  def dispatch(%{id: id} = command) do
    with true <- Vereine.Command.valid?(command),
         %__MODULE__{} = data <- get_aggregate(id),
         {:ok, event} <- execute(data, command),
         {:ok, _pid} <- maybe_start_server(id),
         :ok <- publish_event(id, event) do
      {:ok, event}
    else
      err -> {:error, err}
    end
  end

  def maybe_start_server(id) do
    case Process.whereis(:"#{id}") do
      nil -> {:ok, _pid} = start_link(id)
      pid -> {:ok, pid}
    end
  end

  def get_aggregate(id) do
    :"#{id}"
    |> Process.whereis()
    |> fetch_data()
  end

  def fetch_data(nil) do
    %__MODULE__{}
  end

  def fetch_data(pid) do
    {:ok, %{data: %__MODULE__{} = data}} = get(pid)
    data
  end

  def get(id), do: GenServer.call(:"#{id}", :get)

  def handle_info({:publish_event, event}, %{data: data} = state) do
    {:noreply, %{state | data: apply_event(data, event)}}
  end

  def apply_event(state, %ApplicationAccepted{}) do
    %{state | status: 'accepted'}
  end

  def apply_event(state, %ApplicationRejected{}) do
    %{state | status: 'rejected'}
  end

  def apply_event(state, %ApplicationSubmitted{name: name}) do
    %{state | status: 'open', name: name}
  end

  def apply(state, event) do
    Logger.info("Event not support for #{event.__struct__}")
    state
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
