defmodule Web.Organizations.EventHandler do
  require Logger

  alias Web.Organizations.{
    Repo,
    Organization
  }

  alias Vereine.Events.{
    ApplicationAccepted,
    ApplicationRejected,
    ApplicationSubmitted
  }

  def handle_event(%ApplicationSubmitted{id: id, name: name}) do
    %{id: id, name: name, status: 'inactive'}
    |> Organization.new()
    |> Repo.store()
  end

  def handle_event(%ApplicationAccepted{id: id}) do
    Repo.one(id)
    |> Organization.change(%{status: 'active'})
    |> Repo.store()
  end

  def handle_event(%ApplicationRejected{id: id}) do
    Repo.one(id)
    |> Organization.change(%{status: 'rejected'})
    |> Repo.store()
  end

  def handle_event(event) do
    Logger.info("Event not handled: #{event.__struct__}")
  end
end
