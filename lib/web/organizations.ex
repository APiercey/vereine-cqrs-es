defmodule Web.Organizations do
  alias Web.Organizations.{
    Repo,
    EventHandler
  }

  defdelegate all(), to: Repo
  defdelegate one(id), to: Repo
  defdelegate publish_event(event), to: EventHandler, as: :handle_event
end
