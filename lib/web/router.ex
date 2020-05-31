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
    execute_operation(conn, Web.Operations.Application.AllowEmployment)
  end

  patch "/applications/:application_id/allow_funding" do
    execute_operation(conn, Web.Operations.Application.AllowFunding)
  end

  post "/applications/:application_id/finalize" do
    execute_operation(conn, Web.Operations.Application.FinalizeApplication)
  end

  post "/applications" do
    execute_operation(conn, Web.Operations.Application.SubmitApplication)
  end

  defp execute_operation(conn, module) do
    case module.call(conn) do
      %Plug.Conn{} = conn -> respond_with_success(conn)
      errors -> respond_with_error(conn, errors)
    end
  end

  defp respond_with_success(%Plug.Conn{status: status, assigns: %{body: body}} = conn) do
    conn
    |> put_resp_content_type("application/json")
    |> send_resp(status, Jason.encode!(%{data: body}))
  end

  defp respond_with_error(%Plug.Conn{} = conn, {:error, :validations, errors}) do
    formatted_errors =
      Enum.map(errors, fn {:error, attr, _validation, message} ->
        %{attr => message}
      end)

    conn
    |> put_resp_content_type("application/json")
    |> send_resp(422, Jason.encode!(%{errors: formatted_errors}))
  end
end
