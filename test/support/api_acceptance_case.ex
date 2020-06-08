defmodule Support.ApiAcceptanceCase do
  use ExUnit.CaseTemplate, async: false
  import Support.Api.Helpers
  alias :mnesia, as: Mnesia

  alias Read.Applications.Application
  alias Read.Organizations.Organization

  using do
    quote do
      import Support.ApiAcceptanceCase
      import Support.Api.Helpers
    end
  end

  setup do
    [EventStream, Organization, Application]
    |> Enum.map(&Mnesia.clear_table/1)
    |> Enum.all?(fn {:atomic, :ok} -> true end)

    :ok
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
