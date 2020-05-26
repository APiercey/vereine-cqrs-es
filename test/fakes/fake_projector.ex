defmodule Fakes.FakeProjector do
  use Vereine.Projector

  def handle_event(_event), do: :ok
end
