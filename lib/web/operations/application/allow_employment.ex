defmodule Web.Operations.Application.AllowEmployment do
  def call(%Plug.Conn{params: %{"application_id" => application_id}} = conn) do
    with {:ok, ^application_id} <- Vereine.allow_employment(application_id) do
      conn
      |> Plug.Conn.put_status(202)
      |> Plug.Conn.assign(:body, %{id: application_id})
    end
  end
end
