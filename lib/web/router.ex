defmodule Web.Router do
  use Plug.Router

  plug(:match)

  plug(Plug.Parsers,
    parsers: [:json],
    pass: ["application/json"],
    json_decoder: {Jason, :decode!, [[keys: :atoms]]}
  )

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
    with :ok <- validate(conn, name: [presence: true]) do
      {:ok, %{id: UUID.uuid4()}}
    else
      {:error, _error} = error_result -> error_result
    end
    |> prepare_response
    |> case do
      {:ok, result} ->
        respond(conn, 202, result)

      {:error, result} ->
        respond(conn, 422, result)
    end
  end

  defp validate(%Plug.Conn{body_params: body_params}, validations) do
    if Vex.valid?(body_params, validations) do
      :ok
    else
      {:error, Vex.results(body_params, validations)}
    end
  end

  defp respond(%Plug.Conn{} = conn, status, data) do
    conn
    |> put_resp_content_type("application/json")
    |> send_resp(status, Jason.encode!(data))
  end

  defp prepare_response({:ok, data}), do: {:ok, %{data: data}}

  defp prepare_response({:error, errors}) do
    formatted_errors = Enum.map(errors, &format_error/1)
    {:error, %{errors: formatted_errors}}
  end

  defp format_error({:error, attr, _validation, message}),
    do: %{attr => message}
end
