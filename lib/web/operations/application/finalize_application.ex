defmodule Web.Operations.Application.FinalizeApplication do
  def call(%Plug.Conn{params: %{"application_id" => application_id}} = conn) do
    with {:ok, ^application_id} <- Vereine.finalize_application(application_id) do
      conn
      |> Plug.Conn.put_status(202)
      |> Plug.Conn.assign(:body, %{id: application_id})
    end
  end
end
