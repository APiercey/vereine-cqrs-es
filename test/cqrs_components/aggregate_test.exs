defmodule CQRSComponents.AggregateTest do
  use Support.DataCase, async: false

  alias Fakes.{
    FakeAggregate,
    FakeCommand,
    FakeEvent
  }

  def fixture(:command, opts \\ []),
    do: %FakeCommand{
      id: Keyword.get(opts, :id, "test"),
      message: Keyword.get(opts, :message, "I will never financially recover from this.")
    }

  setup_all do
    :ok = Application.start(:vereine)

    on_exit(fn ->
      :ok = Application.stop(:vereine)
    end)

    :ok
  end

  describe "dispatch/1" do
    test "returns :ok and event when successful" do
      %{id: id} = command = fixture(:command)

      assert {:ok, ^id} = FakeAggregate.dispatch(command)
    end

    test "publishes event to the :event_stream" do
      %{id: id, message: message} =
        command = fixture(:command, message: "Jeff Lowe stole the zoo")

      Registry.register(:event_stream, id, [])

      assert {:ok, _} = FakeAggregate.dispatch(command)
      assert_receive {:publish_event, %FakeEvent{message: ^message}}
    end

    test "multiple aggregates don't share event streams" do
      %{id: expected_id} = command_one = fixture(:command, id: "one")
      %{id: _unexpected_id} = command_two = fixture(:command, id: "two")

      Registry.register(:event_stream, expected_id, [])

      assert {:ok, _} = FakeAggregate.dispatch(command_two)
      assert {:ok, _} = FakeAggregate.dispatch(command_one)
      assert_receive {:publish_event, %FakeEvent{id: ^expected_id}}
    end
  end

  describe "get/1" do
    test "returns state of living aggregate" do
      command = fixture(:command)

      assert {:ok, id} = FakeAggregate.dispatch(command)
      assert {:ok, %{data: %FakeAggregate{id: ^id}, pid_tuples: []}} = FakeAggregate.get(id)
    end

    test "returns :error when aggregate is not alive" do
      id = "does-not-exist"

      assert {:error, message} = FakeAggregate.get(id)
      assert message =~ "not alive"
      assert message =~ id
    end
  end

  describe "an aggregate that dies" do
    test "is revived with previous state" do
      %{id: id, message: message} = command = fixture(:command)

      assert {:ok, ^id} = FakeAggregate.dispatch(command)

      ref = Process.monitor(:"#{id}")

      assert :"#{id}"
             |> Process.whereis()
             |> Process.exit(:brutalkill)

      assert_receive {:DOWN, ^ref, :process, _, :brutalkill}, 500

      # Force VM to context switch to another process
      :timer.sleep(1)

      assert {:ok, %{data: %{message: ^message}}} = FakeAggregate.get(id)
    end
  end
end
