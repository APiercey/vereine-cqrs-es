defmodule CQRSComponents.EventStreamTest do
  use Support.DataCase

  alias CQRSComponents.EventStream

  def fixture(:event),
    do: %{id: "uuid-1", message: "Are the animals happy? Who the hell knows."}

  describe "store/2" do
    test "returns :ok when an event is stored" do
      assert :ok = EventStream.store_event("uuid-1", fixture(:event))
    end
  end

  describe "fetch_events_by_aggregate_id/1" do
    setup do
      1..10
      |> Enum.map(fn _ -> fixture(:event) end)
      |> Enum.map(&EventStream.store_event("uuid-1", &1))

      :ok
    end

    test "returns a collection of events" do
      assert 10 =
               "uuid-1"
               |> EventStream.fetch_events_by_aggregate_id()
               |> Enum.count()
    end
  end
end
