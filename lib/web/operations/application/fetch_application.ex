defmodule Web.Operations.Application.FetchApplication do
  alias Read.Applications

  def call(%Plug.Conn{params: %{"application_id" => application_id}} = conn) do
    with %Applications.Application{} = application <- Applications.one(application_id) do
      conn
      |> Plug.Conn.put_status(200)
      |> Plug.Conn.assign(:body, render(application))
    end
  end

  defp render(%Applications.Application{id: id, organization_id: organization_id, status: status}) do
    %{
      id: id,
      organization_id: organization_id,
      status: status
    }
  end
end
