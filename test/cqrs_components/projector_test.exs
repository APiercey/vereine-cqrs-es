defmodule CQRSComponents.ProjectorTest do
  use Support.DataCase

  alias CQRSComponents.Event

  alias Fakes.{
    FakeProjector,
    FakeEvent,
    FakeSlowEvent
  }

  def fixture(:event, opts \\ []) do
    Event.new(
      Keyword.get(opts, :id, UUID.uuid4()),
      Keyword.get(opts, :event, %FakeEvent{
        message: "I saw a tiger, and the tiger saw a man"
      })
    )
    |> Event.generate_event_id()
    |> Event.generate_timestamp()
  end

  setup do
    id = UUID.uuid4()
    name = FakeProjector.process_name(id)

    {:ok, pid} = GenServer.start(FakeProjector, [id, name], name: name)

    %{id: id, name: name}
  end

  describe "get/1" do
    test "returns state of living projector", %{id: id} do
      assert {:ok, %{checkpoint: _}} = FakeProjector.get(id)
    end

    test "returns :error when projector is not alive" do
      assert {:error, message} = FakeProjector.get("does-not-exist")
      assert message =~ "not alive"
      assert message =~ "does-not-exist"
    end
  end

  describe "subscribes to :event_stream" do
    test "handles a events", %{id: id} do
      %{event_id: event_id} = event = fixture(:event, id: id)

      publish_event(event, id)

      assert {:ok, %{checkpoint: ^event_id}} = FakeProjector.get(id)
    end
  end

  describe "a projector that dies" do
    test "will be revived with previous state", %{id: id, name: name} do
      %{event_id: event_id} = event = fixture(:event, id: id)

      publish_event(event, id)

      assert {:ok, %{checkpoint: ^event_id}} = FakeProjector.get(id)

      ref = Process.monitor(name)

      assert name
             |> Process.whereis()
             |> Process.exit(:brutalkill)

      assert_receive {:DOWN, ^ref, :process, _, :brutalkill}, 500

      {:ok, pid} = GenServer.start(FakeProjector, [id, name], name: name)

      # Force VM to context switch to another process
      :timer.sleep(100)

      assert {:ok, %{checkpoint: ^event_id}} = FakeProjector.get(id)
    end

    test "will process old events" do
      id = UUID.uuid4()
      name = FakeProjector.process_name(id)

      {:ok, %{event_id: event_id}} =
        CQRSComponents.EventStream.store_event(id, %FakeEvent{id: id, message: "I come after!"})

      {:ok, pid} = GenServer.start(FakeProjector, [id, name], name: name)

      # Force VM to context switch to another process
      :timer.sleep(1)

      assert {:ok, %{checkpoint: ^event_id}} = FakeProjector.get(id)
    end
  end

  def publish_event(event, id) do
    Registry.dispatch(:event_stream, id, fn entries ->
      entries
      |> Enum.map(fn {pid, _} -> pid end)
      |> Enum.map(fn pid -> send(pid, {:publish_event, event}) end)
    end)

    event
  end
end
