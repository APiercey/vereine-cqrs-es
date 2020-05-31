defmodule Web.Applications.FinalizeTest do
  use Support.ApiAcceptanceCase

  describe "[POST] 202 /applications/:application_id/finalize" do
    setup do
      %{"id" => id} = create_application()

      %{application_id: id}
    end

    test "endpoint behaviour", %{application_id: application_id} do
      application_id
      |> url()
      |> post!("")
      |> returns_status(202)
      |> returns_json_header()
      |> returns_nested_data()
    end

    test "returns application ID", %{application_id: application_id} do
      assert %{"id" => _id} =
               application_id
               |> url()
               |> post!(Jason.encode!(""))
               |> parse_body()
               |> pluck_data
    end
  end

  def url(application_id) do
    "/applications/#{application_id}/finalize" |> path()
  end

  defp create_application() do
    "/applications"
    |> path()
    |> post!(Jason.encode!(%{name: "B.C.R. Zoo"}))
    |> parse_body()
    |> pluck_data
  end
end
