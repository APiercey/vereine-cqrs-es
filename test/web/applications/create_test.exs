defmodule Web.Applications.CreateTest do
  use Support.ApiAcceptanceCase

  @valid_body %{name: "G.W. Zoo"}
  @invalid %{name: ""}

  describe "[POST] 202 /applications" do
    test "endpoint behaviour" do
      "/applications"
      |> path()
      |> post!(Jason.encode!(@valid_body))
      |> returns_status(202)
      |> returns_json_header()
      |> returns_nested_data()
    end

    test "returns application ID" do
      assert %{"id" => _id} =
               "/applications"
               |> path()
               |> post!(Jason.encode!(@valid_body))
               |> parse_body()
               |> pluck_data
    end

    test "invalid attributes results in failure" do
      "/applications"
      |> path()
      |> post!(Jason.encode!(@invalid_body))
      |> returns_status(422)
    end
  end
end
