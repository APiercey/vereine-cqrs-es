defmodule Vereine.Aggregates.OrganizationTest do
  use ExUnit.Case

  alias Vereine.Aggregates.Organization

  alias Vereine.Commands.{
    SubmitApplication,
    AddFeature,
    FinalizeApplication
  }

  alias Vereine.Events.{
    ApplicationSubmitted,
    ApplicationAccepted,
    ApplicationRejected,
    FeatureAdded
  }

  def fixture(:submit_application),
    do: %SubmitApplication{id: 'test', name: 'test'}

  def fixture(:add_feature),
    do: %AddFeature{id: 'test', feature: :employeer}

  def fixture(:finalize_application),
    do: %FinalizeApplication{id: 'test'}

  describe "execute/2 SubmitApplication command" do
    test "returns ApplicationSubmitted event when application is not open" do
      %{name: name} = command = fixture(:submit_application)

      assert {:ok, %ApplicationSubmitted{name: ^name}} =
               Organization.execute(%Organization{id: nil}, command)
    end

    test "returns :error if application already submitted" do
      command = fixture(:submit_application)

      assert {:error, error} = Organization.execute(%Organization{status: 'open'}, command)
      assert error =~ "already submitted"
    end

    test "returns :error if application has a status other than open" do
      command = fixture(:submit_application)

      assert {:error, error} =
               Organization.execute(%Organization{status: 'random_status'}, command)

      assert error =~ "cannot be changed"
    end
  end

  describe "execute/2 AddFeature command" do
    test "returns FeatureAdded event when application is open" do
      %{feature: feature} = command = fixture(:add_feature)

      assert {:ok, %FeatureAdded{feature: ^feature}} =
               Organization.execute(%Organization{status: 'open'}, command)
    end

    test "returns :error if application has not been submitted" do
      command = fixture(:add_feature)

      assert {:error, error} = Organization.execute(%Organization{status: nil}, command)
      assert error =~ "cannot be added"
    end

    test "returns :error if application has status other than open" do
      command = fixture(:add_feature)

      assert {:error, error} =
               Organization.execute(%Organization{status: 'random_status'}, command)

      assert error =~ "cannot be added"
    end
  end

  describe "execute/2 FinalizeApplication command" do
    test "returns ApplicationAccepted event when application is open and valid" do
      command = fixture(:finalize_application)

      assert {:ok, %ApplicationAccepted{}} =
               %Organization{status: 'open', name: 'test'}
               |> Organization.execute(command)
    end

    test "returns ApplicationRejected event when application is open and invalid" do
      command = fixture(:finalize_application)

      assert {:ok, %ApplicationRejected{}} =
               %Organization{status: 'open', name: nil}
               |> Organization.execute(command)
    end

    test "returns :error if application has already been finalized" do
      command = fixture(:finalize_application)

      assert {:error, error} = Organization.execute(%Organization{status: nil}, command)
      assert error =~ "already finalized"
    end
  end

  describe "apply_event/2" do
    test "application is accepted with features" do
      id = "985a1caf-3fe9-4338-93ed-905409251013"
      name = "Fancy name!"

      assert %Organization{id: ^id, name: ^name, status: 'accepted'} =
               [
                 %ApplicationSubmitted{id: id, name: name},
                 %FeatureAdded{id: id},
                 %ApplicationAccepted{id: id}
               ]
               |> Enum.reduce(
                 %Organization{id: id},
                 &Organization.apply_event(&2, &1)
               )
    end

    test "application is rejected with features" do
      id = "985a1caf-3fe9-4338-93ed-905409251013"
      name = "Fancy name!"

      assert %Organization{id: ^id, name: ^name, status: 'rejected'} =
               [
                 %ApplicationSubmitted{id: id, name: name},
                 %ApplicationRejected{id: id}
               ]
               |> Enum.reduce(
                 %Organization{id: id},
                 &Organization.apply_event(&2, &1)
               )
    end
  end
end
