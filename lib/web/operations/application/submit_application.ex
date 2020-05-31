defmodule Web.Operations.Application.SubmitApplication do
  @validations [name: [presence: true]]

  def call(%Plug.Conn{} = conn) do
    with %{body_params: body_params} <- conn,
         :ok <- validate_body_params(body_params, @validations),
         {:ok, id} <- Vereine.submit_application(body_params) do
      conn
      |> Plug.Conn.put_status(202)
      |> Plug.Conn.assign(:body, %{id: id})
    end
  end

  defp validate_body_params(body_params, validations) do
    if Vex.valid?(body_params, validations) do
      :ok
    else
      {:error, :validations, Vex.results(body_params, validations)}
    end
  end
end
