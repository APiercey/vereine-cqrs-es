defmodule Read.EventHandler do
  require Logger

  alias Read.{
    Applications,
    Organizations
  }

  alias Vereine.Events.{
    ApplicationAccepted,
    ApplicationRejected,
    ApplicationSubmitted,
    FeatureAdded,
    OrganizationCreated
  }

  def handle_event(%ApplicationSubmitted{id: id, name: name}) do
    {:ok, _application} =
      %{id: id, name: name, status: 'active'}
      |> Applications.Application.new()
      |> Applications.Repo.store()

    :ok
  end

  def handle_event(%FeatureAdded{id: id, feature: feature}) do
    {:ok, _application} = update_application(id, changes_for_feature(feature))

    :ok
  end

  def handle_event(%ApplicationAccepted{id: id}) do
    {:ok, _application} = update_application(id, %{status: 'accepted'})

    :ok
  end

  def handle_event(%ApplicationRejected{id: id}) do
    {:ok, _application} = update_application(id, %{status: 'rejected'})

    :ok
  end

  def handle_event(%OrganizationCreated{id: id, application_id: application_id}) do
    with %Applications.Application{name: name} <- Applications.Repo.one(application_id),
         {:ok, _} <- update_application(application_id, %{organization_id: id}),
         {:ok, _} <- create_organization(%{id: id, application_id: application_id, name: name}) do
      :ok
    end
  end

  def handle_event(event) do
    Logger.info("Event not handled: #{event.__struct__}")
    :ok
  end

  defp changes_for_feature(:employeer), do: %{can_hire: true}
  defp changes_for_feature(:fundable), do: %{can_aquire_funding: true}

  defp create_organization(attrs) do
    attrs
    |> Organizations.Organization.new()
    |> Organizations.Repo.store()
  end

  defp update_application(id, attrs) do
    Applications.Repo.one(id)
    |> Applications.Application.change(attrs)
    |> Applications.Repo.store()
  end
end
