defmodule Vereine.Projecters.ApplicationFinalizationTest do
  use ExUnit.Case

  alias Vereine.Commands.CreateOrganization
  alias Vereine.Events.ApplicationAccepted
  alias Vereine.Projecters.ApplicationFinalization

  describe "handling ApplicationAccepted" do
    test "returns CreateOrganization" do
      assert {:dispatch, %CreateOrganization{}} =
               %ApplicationAccepted{id: "test"} |> ApplicationFinalization.handle_event()
    end
  end
end
