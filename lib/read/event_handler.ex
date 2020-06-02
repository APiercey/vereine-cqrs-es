defmodule Read.EventHandler do
  require Logger

  alias Read.Applications

  alias Vereine.Events.{
    ApplicationAccepted,
    ApplicationRejected,
    ApplicationSubmitted,
    FeatureAdded
  }

  def handle_event(%ApplicationSubmitted{id: id, name: name}) do
    {:ok, _org} =
      %{id: id, name: name, status: 'inactive'}
      |> Applications.Application.new()
      |> Applications.Repo.store()

    :ok
  end

  def handle_event(%FeatureAdded{id: id, feature: feature}) do
    with changes <- changes_for_feature(feature),
         {:ok, _org} <-
           Applications.Repo.one(id)
           |> Applications.Application.change(changes)
           |> Applications.Repo.store() do
      :ok
    end
  end

  def handle_event(%ApplicationAccepted{id: id}) do
    {:ok, _org} =
      Applications.Repo.one(id)
      |> Applications.Application.change(%{status: 'active'})
      |> Applications.Repo.store()

    :ok
  end

  def handle_event(%ApplicationRejected{id: id}) do
    {:ok, _org} =
      Applications.Repo.one(id)
      |> Applications.Application.change(%{status: 'rejected'})
      |> Applications.Repo.store()

    :ok
  end

  def handle_event(event) do
    Logger.info("Event not handled: #{event.__struct__}")
    :ok
  end

  defp changes_for_feature(:employeer), do: %{can_hire: true}
  defp changes_for_feature(:fundable), do: %{can_aquire_funding: true}
end
