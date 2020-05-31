defmodule Web.Router do
  use Plug.Router
  use Plug.ErrorHandler

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
    {:ok, data} = {:ok, %{id: UUID.uuid4()}} |> prepare_response

    respond(conn, 202, data)
  end

  patch "/applications/:application_id/allow_funding" do
    {:ok, data} = {:ok, %{id: UUID.uuid4()}} |> prepare_response

    respond(conn, 202, data)
  end

  post "/applications/:application_id/finalize" do
    {:ok, data} = {:ok, %{id: UUID.uuid4()}} |> prepare_response

    respond(conn, 202, data)
  end

  post "/applications" do
    with %{body_params: body_params} <- conn,
         :ok <- validate_body_params(body_params, name: [presence: true]),
         {:ok, id} <- Vereine.submit_antrag(body_params) do
      {:ok, %{id: id}}
    else
      {:error, _component, _error} = error_result -> error_result
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

  defp validate_body_params(body_params, validations) do
    if Vex.valid?(body_params, validations) do
      :ok
    else
      {:error, :validations, Vex.results(body_params, validations)}
    end
  end

  defp respond(%Plug.Conn{} = conn, status, data) do
    conn
    |> put_resp_content_type("application/json")
    |> send_resp(status, Jason.encode!(data))
  end

  defp prepare_response({:ok, data}), do: {:ok, %{data: data}}

  defp prepare_response({:error, :validations, errors}) do
    formatted_errors =
      Enum.map(errors, fn {:error, attr, _validation, message} ->
        %{attr => message}
      end)

    {:error, %{errors: formatted_errors}}
  end

  defp prepare_response({:error, message}), do: {:error, %{errors: [message]}}
end
