defmodule Vereine.Projecters.UpdateWeb do
  use CQRSComponents.Projector

  def handle_event(event) do
    :ok = Web.Organizations.publish_event(event)
    :ok
  end
end
