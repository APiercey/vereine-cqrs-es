defmodule Web.Applications.FinalizeTest do
  use Support.ApiAcceptanceCase

  @valid_body ""

  describe "[POST] 202 /applications/:application_id/finalize" do
    setup do
      %{"id" => id} = create_application()

      %{application_id: id}
    end

    test "endpoint behaviour", %{application_id: application_id} do
      "/applications/#{application_id}/finalize"
      |> path()
      |> post!("")
      |> returns_status(202)
      |> returns_json_header()
      |> returns_nested_data()
    end

    test "returns application ID", %{application_id: application_id} do
      assert %{"id" => _id} =
               "/applications/#{application_id}/finalize"
               |> path()
               |> post!(Jason.encode!(@valid_body))
               |> parse_body()
               |> pluck_data
    end
  end

  defp create_application() do
    "/applications"
    |> path()
    |> post!(Jason.encode!(%{test: "world"}))
    |> parse_body()
    |> pluck_data
  end
end
