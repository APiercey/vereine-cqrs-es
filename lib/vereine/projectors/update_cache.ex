defmodule Vereine.Projecters.UpdateCache do
  use GenServer
  require Logger

  def start_link(id) do
    GenServer.start_link(__MODULE__, id, name: __MODULE__)
  end

  def init(id) do
    {:ok, _} = Registry.register(:event_stream, id, [])
    {:ok, []}
  end

  def handle_info({:publish_event, event}, state) do
    Logger.info("Received event: #{event.__struct__}")
    {:noreply, [state | event]}
  end
end
