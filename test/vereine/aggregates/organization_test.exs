defmodule Vereine.Aggregates.OrganizationTest do
  use ExUnit.Case

  alias Vereine.Aggregates.Organization

  alias Vereine.Commands.{
    CreateOrganization
  }

  alias Vereine.Events.{
    OrganizationCreated
  }

  def fixture(:create_organization),
    do: %CreateOrganization{id: 'organization-uuid', application_id: 'application-uuid'}

  describe "execute/2 CreateOrganization command" do
    test "returns OrganizationCreated" do
      %{application_id: application_id, id: id} = command = fixture(:create_organization)

      assert {:ok, %OrganizationCreated{application_id: ^application_id}} =
               Organization.execute(%Organization{id: id}, command)
    end
  end

  describe "apply_event/2" do
    test "organization is created with status 'created'" do
      id = "ff3a5dad-157d-400d-87b4-e5074097a7c6"
      application_id = "7726ad47-44ac-4b12-8d44-72cedd70d72d"

      assert %Organization{id: ^id, application_id: ^application_id, status: 'created'} =
               [
                 %OrganizationCreated{id: id, application_id: application_id}
               ]
               |> Enum.reduce(
                 %Organization{id: id},
                 &Organization.apply_event(&2, &1)
               )
    end
  end
end
