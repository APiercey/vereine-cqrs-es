defmodule Fakes.FakeProjector do
  use CQRSComponents.Projector

  def handle_event(_event), do: :ok
end
