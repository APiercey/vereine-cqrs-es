defmodule Web.Applications.AllowFundingTest do
  use Support.ApiAcceptanceCase

  describe "[PATCH] 202 /applications/:application_id/allow_funding" do
    setup do
      %{"id" => id} = create_application()

      %{application_id: id}
    end

    test "endpoint behaviour", %{application_id: application_id} do
      application_id
      |> url
      |> patch!("")
      |> returns_status(202)
      |> returns_json_header()
      |> returns_nested_data()
    end

    test "returns application ID", %{application_id: application_id} do
      assert %{"id" => _id} =
               application_id
               |> url
               |> patch!("")
               |> parse_body()
               |> pluck_data
    end
  end

  defp url(application_id) do
    "/applications/#{application_id}/allow_funding" |> path()
  end

  defp create_application() do
    "/applications"
    |> path()
    |> post!(Jason.encode!(%{test: "world"}))
    |> parse_body()
    |> pluck_data
  end
end
