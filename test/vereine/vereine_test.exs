defmodule VereineTest do
  use Support.DataCase

  @valid_attributes %{name: "My Newest Aggregate"}
  @invalid_attributes %{}

  describe "submit_application/1" do
    test "with valid attributes" do
      assert {:ok, _id} = Vereine.submit_application(@valid_attributes)
    end

    test "with invalid attributes" do
      assert {:error, message} = Vereine.submit_application(@invalid_attributes)
      assert message =~ "invalid"
    end
  end

  describe "allow_employment/1" do
    setup do
      {:ok, id} = Vereine.submit_application(@valid_attributes)

      %{application_id: id}
    end

    test "with an open application", %{application_id: application_id} do
      assert {:ok, ^application_id} = Vereine.allow_employment(application_id)
    end
  end

  describe "allow_funding/1" do
    setup do
      {:ok, id} = Vereine.submit_application(@valid_attributes)

      %{application_id: id}
    end

    test "with an open application", %{application_id: application_id} do
      assert {:ok, ^application_id} = Vereine.allow_funding(application_id)
    end
  end

  describe "finalize_application/1" do
    setup do
      {:ok, id} = Vereine.submit_application(@valid_attributes)

      %{application_id: id}
    end

    test "with an open application", %{application_id: application_id} do
      assert {:ok, ^application_id} = Vereine.finalize_application(application_id)
    end
  end
end
