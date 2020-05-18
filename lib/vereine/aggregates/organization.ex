defmodule Vereine.Aggregates.Organization do
  use GenServer
  require Logger

  defstruct [:id, :status, :name, :can_hire, :can_aquire_funding]

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
    with {:ok, update_cache_pid} <- UpdateCache.start_link(id) do
      {:ok, %{data: data, update_cache_pid: update_cache_pid}}
    else
      err -> {:error, err}
    end
  end

  def generate_id(), do: UUID.uuid4()

  def apply(%{id: id} = event) do
    {:ok, pid} =
      case Process.whereis(:"#{id}") do
        nil -> {:ok, _pid} = start_link(id)
        pid -> {:ok, pid}
      end

    :ok = GenServer.cast(pid, {:apply_event, event})
  end

  def execute(%SubmitApplication{id: id, name: name} = command) do
    with true <- Vereine.Command.valid?(command),
         nil <- Process.whereis(:"#{id}"),
         event <- %ApplicationSubmitted{id: id, name: name},
         :ok <- apply(event),
         :ok <- publish_event(id, event) do
      {:ok, event}
    else
      err -> {:error, err}
    end
  end

  def execute(%FinalizeApplication{id: id} = command) do
    with true <- Vereine.Command.valid?(command),
         {:ok, %{data: data}} <- get(id),
         {:status_check, %{status: 'open'}} <- {:status_check, data},
         {:event, event} <- {:event, accept_or_reject_application(data)},
         :ok <- apply(event),
         :ok <- publish_event(id, event) do
      {:ok, event}
    else
      err -> {:error, err}
    end
  end

  def execute(%AddFeature{id: id} = command) do
    with true <- Vereine.Command.valid?(command),
         {:ok, %{data: data}} <- get(id),
         %{status: 'open'} <- data,
         event <- %FeatureAdded{id: id, feature: command.feature},
         :ok <- apply(event),
         :ok <- publish_event(id, event) do
      {:ok, event}
    else
      err -> {:error, err}
    end
  end

  def accept_or_reject_application(%{id: id, name: nil}),
    do: %ApplicationRejected{id: id}

  def accept_or_reject_application(%{id: id}),
    do: %ApplicationAccepted{id: id}

  def get(id),
    do: GenServer.call(:"#{id}", :get)

  def handle_cast(
        {:apply_event, %ApplicationSubmitted{name: name}},
        %{data: data} = state
      ) do
    new_data = %{data | status: 'open', name: name}
    new_state = %{state | data: new_data}
    {:noreply, new_state}
  end

  def handle_cast({:apply_event, %ApplicationAccepted{}}, %{data: data} = state) do
    new_data = %{data | status: 'approved'}
    new_state = %{state | data: new_data}
    {:noreply, new_state}
  end

  def handle_cast({:apply_event, %ApplicationRejected{}}, %{data: data} = state) do
    new_data = %{data | status: 'rejected'}
    new_state = %{state | data: new_data}
    {:noreply, new_state}
  end

  def handle_cast({:apply_event, %FeatureAdded{feature: :employeer}}, %{data: data} = state) do
    new_data = %{data | can_hire: true}
    new_state = %{state | data: new_data}
    {:noreply, new_state}
  end

  def handle_cast({:apply_event, %FeatureAdded{feature: :fundable}}, %{data: data} = state) do
    new_data = %{data | can_aquire_funding: true}
    new_state = %{state | data: new_data}
    {:noreply, new_state}
  end

  def handle_cast({:apply_event, event}, state) do
    Logger.info("Event not support for #{event.__struct__}")
    {:noreply, state}
  end

  def handle_call(:get, _from, state),
    do: {:reply, {:ok, state}, state}

  defp publish_event(id, event) do
    Logger.info("Publish event")

    Registry.dispatch(:event_stream, id, fn entries ->
      for {pid, _} <- entries do
        send(pid, {:publish_event, event})
      end
    end)

    :ok
  end
end
