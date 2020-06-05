defmodule Web.Applications.ShowTest do
  use Support.ApiAcceptanceCase

  describe "[GET] 200 /applications/:application_id" do
    setup do
      %{"id" => id} = create_application()

      %{application_id: id}
    end

    test "endpoint behaviour", %{application_id: application_id} do
      application_id
      |> url()
      |> get!()
      |> returns_status(200)
      |> returns_json_header()
      |> returns_nested_data()
    end

    test "returns application information", %{application_id: application_id} do
      assert %{"id" => ^application_id, "organization_id" => _, "status" => _} =
               application_id
               |> url()
               |> get!()
               |> parse_body()
               |> pluck_data
    end
  end

  def url(application_id) do
    "/applications/#{application_id}" |> path()
  end

  defp create_application() do
    "/applications"
    |> path()
    |> post!(Jason.encode!(%{name: "B.C.R. Zoo"}))
    |> parse_body()
    |> pluck_data
  end
end
