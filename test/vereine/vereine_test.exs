defmodule VereineTest do
  use Support.DataCase

  @valid_attributes %{name: "My Newest Aggregate"}
  @invalid_attributes %{}

  describe "submit_antrag/1" do
    test "with valid attributes" do
      assert {:ok, _id} = Vereine.submit_antrag(@valid_attributes)
    end

    test "with invalid attributes" do
      assert {:error, message} = Vereine.submit_antrag(@invalid_attributes)
      assert message =~ "invalid"
    end
  end

  describe "allow_employment/1" do
    setup do
      {:ok, id} = Vereine.submit_antrag(@valid_attributes)

      %{antrag_id: id}
    end

    test "with an open antrag", %{antrag_id: antrag_id} do
      assert {:ok, ^antrag_id} = Vereine.allow_employment(antrag_id)
    end
  end

  describe "allow_funding/1" do
    setup do
      {:ok, id} = Vereine.submit_antrag(@valid_attributes)

      %{antrag_id: id}
    end

    test "with an open antrag", %{antrag_id: antrag_id} do
      assert {:ok, ^antrag_id} = Vereine.allow_funding(antrag_id)
    end
  end

  describe "finalize_antrag/1" do
    setup do
      {:ok, id} = Vereine.submit_antrag(@valid_attributes)

      %{antrag_id: id}
    end

    test "with an open antrag", %{antrag_id: antrag_id} do
      assert {:ok, ^antrag_id} = Vereine.finalize_antrag(antrag_id)
    end
  end
end
