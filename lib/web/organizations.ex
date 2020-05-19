defmodule Web.Organizations do
  alias Web.Organizations.{
    Repo
    Organization
  }

  alias Vereine.Events.{
    ApplicationAccepted,
    ApplicationRejected,
    ApplicationSubmitted,
    FeatureAdded
  }

  defdelegate all(), to: Repo
  defdelegate one(id), to: Repo

  def handle_event(%ApplicationSubmitted{id: id, name: name}) do
    %{id: id, name: name, status: 'inactive'}
    |> Organization.new()
    |> Persistence.insert()
  end

  def handle_event(%ApplicationAccepted{id: id}) do
    Querying.one(id)
    |> Organization.change(%{status: 'active'})
    |> Persistence.insert()
  end

  def handle_event(%ApplicationRejected{id: id}) do
    Querying.one(id)
    |> Organization.change(%{status: 'rejected'})
    |> Persistence.insert()
  end

  def handle_event(%FeatureAdded{}) do
  end
end
