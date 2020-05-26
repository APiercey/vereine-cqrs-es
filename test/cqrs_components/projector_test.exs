defmodule CQRSComponents.ProjectorTest do
  use ExUnit.Case

  alias Fakes.{
    FakeProjector
  }

  @id "uuid-1"

  setup do
    {:ok, _pid} = FakeProjector.start_link(@id)
    :ok
  end

  describe "get/1" do
    test "returns state of living projector" do
      assert {:ok, []} = FakeProjector.get(@id)
    end

    test "returns :error when projector is not alive" do
      assert {:error, message} = FakeProjector.get("does-not-exist")
      assert message =~ "not alive"
      assert message =~ "does-not-exist"
    end
  end

  describe "subscribes to :event_stream" do
    test "handles a events" do
      event = "I saw a tiger, and the tiger saw a man"
      publish_event(event, @id)

      assert {:ok, [^event]} = FakeProjector.get(@id)
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
