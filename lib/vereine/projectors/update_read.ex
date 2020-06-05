defmodule Vereine.Projecters.UpdateRead do
  use CQRSComponents.Projector

  def handle_event(event) do
    :ok = Read.EventHandler.handle_event(event)
    :ok
  end
end
