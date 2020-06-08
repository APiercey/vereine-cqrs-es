defmodule Support.ApiAcceptanceCase do
  use ExUnit.CaseTemplate, async: false
  import Support.Helpers.Api

  alias Support.Helpers.Database

  using do
    quote do
      import Support.ApiAcceptanceCase
      import Support.Helpers.Api
    end
  end

  setup_all do
    :ok = Application.start(:vereine)

    on_exit(fn ->
      :ok = Application.stop(:vereine)
    end)

    :ok
  end

  setup do
    :ok = Database.clear_database()
  end

  def returns_status(%HTTPoison.Response{} = response, status) do
    assert %{status_code: ^status} = response

    response
  end

  def returns_nested_data(%HTTPoison.Response{} = response) do
    assert %{"data" => _} = response |> parse_body

    response
  end

  def returns_json_header(%HTTPoison.Response{} = response) do
    assert response
           |> parse_headers()
           |> Map.fetch!("content-type")
           |> String.contains?("application/json")

    response
  end
end
