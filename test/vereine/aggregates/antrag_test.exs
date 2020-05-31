defmodule Vereine.Aggregates.ApplicationTest do
  use ExUnit.Case

  alias Vereine.Aggregates.Application

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
               Application.execute(%Application{id: nil}, command)
    end

    test "returns :error if application already submitted" do
      command = fixture(:submit_application)

      assert {:error, error} = Application.execute(%Application{status: 'open'}, command)
      assert error =~ "already submitted"
    end

    test "returns :error if application has a status other than open" do
      command = fixture(:submit_application)

      assert {:error, error} = Application.execute(%Application{status: 'random_status'}, command)

      assert error =~ "cannot be changed"
    end
  end

  describe "execute/2 AddFeature command" do
    test "returns FeatureAdded event when application is open" do
      %{feature: feature} = command = fixture(:add_feature)

      assert {:ok, %FeatureAdded{feature: ^feature}} =
               Application.execute(%Application{status: 'open'}, command)
    end

    test "returns :error if application has not been submitted" do
      command = fixture(:add_feature)

      assert {:error, error} = Application.execute(%Application{status: nil}, command)
      assert error =~ "cannot be added"
    end

    test "returns :error if application has status other than open" do
      command = fixture(:add_feature)

      assert {:error, error} = Application.execute(%Application{status: 'random_status'}, command)

      assert error =~ "cannot be added"
    end
  end

  describe "execute/2 FinalizeApplication command" do
    test "returns ApplicationAccepted event when application is open and valid" do
      command = fixture(:finalize_application)

      assert {:ok, %ApplicationAccepted{}} =
               %Application{status: 'open', name: 'test'}
               |> Application.execute(command)
    end

    test "returns ApplicationRejected event when application is open and invalid" do
      command = fixture(:finalize_application)

      assert {:ok, %ApplicationRejected{}} =
               %Application{status: 'open', name: nil}
               |> Application.execute(command)
    end

    test "returns :error if application has already been finalized" do
      command = fixture(:finalize_application)

      assert {:error, error} = Application.execute(%Application{status: nil}, command)
      assert error =~ "already finalized"
    end
  end

  describe "apply_event/2" do
    test "application is accepted with features" do
      id = "985a1caf-3fe9-4338-93ed-905409251013"
      name = "Fancy name!"

      assert %Application{id: ^id, name: ^name, status: 'accepted'} =
               [
                 %ApplicationSubmitted{id: id, name: name},
                 %FeatureAdded{id: id},
                 %ApplicationAccepted{id: id}
               ]
               |> Enum.reduce(
                 %Application{id: id},
                 &Application.apply_event(&2, &1)
               )
    end

    test "application is rejected with features" do
      id = "985a1caf-3fe9-4338-93ed-905409251013"
      name = "Fancy name!"

      assert %Application{id: ^id, name: ^name, status: 'rejected'} =
               [
                 %ApplicationSubmitted{id: id, name: name},
                 %ApplicationRejected{id: id}
               ]
               |> Enum.reduce(
                 %Application{id: id},
                 &Application.apply_event(&2, &1)
               )
    end
  end
end
