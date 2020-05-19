defmodule Vereine.Projecters.UpdateCache do
  use GenServer
  require Logger

  def start_link(id) do
    GenServer.start_link(__MODULE__, id, name: :"#{__MODULE__}_#{id}")
  end

  def init(id) do
    {:ok, _} = Registry.register(:event_stream, id, [])
    {:ok, []}
  end

  def handle_info({:publish_event, event}, state) do
    Web.OrganizationCache.apply(event)
    {:noreply, [state | event]}
  end
end
