defmodule Web.Operations.Antrag.AllowFunding do
  def call(%Plug.Conn{params: %{"application_id" => application_id}} = conn) do
    conn
    |> Plug.Conn.put_status(202)
    |> Plug.Conn.assign(:body, %{id: application_id})
  end
end
