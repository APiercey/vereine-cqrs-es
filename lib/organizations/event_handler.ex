defmodule Organizations.EventHandler do
  require Logger

  alias Organizations.{
    Repo,
    Organization
  }

  alias Vereine.Events.{
    ApplicationAccepted,
    ApplicationRejected,
    ApplicationSubmitted,
    FeatureAdded
  }

  def handle_event(%ApplicationSubmitted{id: id, name: name}) do
    {:ok, _org} =
      %{id: id, name: name, status: 'inactive'}
      |> Organization.new()
      |> Repo.store()

    :ok
  end

  def handle_event(%FeatureAdded{id: id, feature: feature}) do
    with changes <- changes_for_feature(feature),
         {:ok, _org} <-
           Repo.one(id)
           |> Organization.change(changes)
           |> Repo.store() do
      :ok
    end
  end

  def handle_event(%ApplicationAccepted{id: id}) do
    {:ok, _org} =
      Repo.one(id)
      |> Organization.change(%{status: 'active'})
      |> Repo.store()

    :ok
  end

  def handle_event(%ApplicationRejected{id: id}) do
    {:ok, _org} =
      Repo.one(id)
      |> Organization.change(%{status: 'rejected'})
      |> Repo.store()

    :ok
  end

  def handle_event(event) do
    Logger.info("Event not handled: #{event.__struct__}")
    :ok
  end

  defp changes_for_feature(:employeer), do: %{can_hire: true}
  defp changes_for_feature(:fundable), do: %{can_aquire_funding: true}
end
