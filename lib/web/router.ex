defmodule Web.Router do
  use Plug.Router

  plug(:match)
  plug(:dispatch)

  get("/hcheck", do: send_resp(conn, 200, "200 OK"))
  get("/favicon.ico", do: send_resp(conn, 200, ""))

  patch "/applications/:application_id/allow_employment" do
    data = %{id: UUID.uuid4()} |> prepare_response

    conn
    |> put_resp_content_type("application/json")
    |> send_resp(202, data)
  end

  patch "/applications/:application_id/allow_funding" do
    data = %{id: UUID.uuid4()} |> prepare_response

    conn
    |> put_resp_content_type("application/json")
    |> send_resp(202, data)
  end

  post "/applications/:application_id/finalize" do
    data = %{id: UUID.uuid4()} |> prepare_response

    conn
    |> put_resp_content_type("application/json")
    |> send_resp(202, data)
  end

  post "/applications" do
    data = %{id: UUID.uuid4()} |> prepare_response

    conn
    |> put_resp_content_type("application/json")
    |> send_resp(202, data)
  end

  defp prepare_response(data), do: %{data: data} |> Jason.encode!()
end
