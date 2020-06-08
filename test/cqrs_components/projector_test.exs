defmodule CQRSComponents.ProjectorTest do
  use Support.DataCase

  alias Fakes.FakeProjector

  setup do
    id = UUID.uuid4()

    {:ok, _pid} = FakeProjector.start_link(id)

    %{id: id}
  end

  describe "get/1" do
    test "returns state of living projector", %{id: id} do
      assert {:ok, []} = FakeProjector.get(id)
    end

    test "returns :error when projector is not alive" do
      assert {:error, message} = FakeProjector.get("does-not-exist")
      assert message =~ "not alive"
      assert message =~ "does-not-exist"
    end
  end

  describe "subscribes to :event_stream" do
    test "handles a events", %{id: id} do
      event = "I saw a tiger, and the tiger saw a man"
      publish_event(event, id)

      assert {:ok, [^event]} = FakeProjector.get(id)
    end
  end

  def publish_event(event, id) do
    Registry.dispatch(:event_stream, id, fn entries ->
      entries
      |> Enum.map(fn {pid, _} -> pid end)
      |> Enum.map(fn pid -> send(pid, {:publish_event, event}) end)
    end)
  end
end
