defmodule Web.ApiTest do
  use Support.ApiAcceptanceCase

  describe "[GET] 200 /hcheck" do
    test "endpoint behaviour" do
      "/hcheck"
      |> path()
      |> get!()
      |> returns_status(200)
    end
  end

  describe "[POST] 202 /applications" do
    @valid_body %{test: "world"}

    test "endpoint behaviour" do
      "/applications"
      |> path()
      |> patch!(Jason.encode!(@valid_body))
      |> returns_status(202)
      |> returns_json_header()
      |> returns_nested_data()
    end

    test "returns application ID" do
      assert %{"id" => _id} =
               "/applications"
               |> path()
               |> patch!(Jason.encode!(@valid_body))
               |> parse_body()
               |> pluck_data
    end
  end

  describe "[POST] 202 /applications/:application_id/features" do
    @valid_body %{test: "world"}

    setup do
      %{"id" => id} = submit_application()

      %{application_id: id}
    end

    test "endpoint behaviour", %{application_id: application_id} do
      "/applications/#{application_id}/features"
      |> path()
      |> patch!(Jason.encode!(@valid_body))
      |> returns_status(202)
      |> returns_json_header()
      |> returns_nested_data()
    end

    test "returns application ID", %{application_id: application_id} do
      assert %{"id" => _id} =
               "/applications/#{application_id}/features"
               |> path()
               |> patch!(Jason.encode!(@valid_body))
               |> parse_body()
               |> pluck_data
    end
  end

  def submit_application() do
    "/applications"
    |> path()
    |> patch!(Jason.encode!(@valid_body))
    |> parse_body()
    |> pluck_data
  end

  describe "[POST] 202 /applications/:application_id/finalize" do
    setup do
      %{"id" => id} = submit_application()

      %{application_id: id}
    end

    test "endpoint behaviour", %{application_id: application_id} do
      "/applications/#{application_id}/finalize"
      |> path()
      |> patch!(Jason.encode!(@valid_body))
      |> returns_status(202)
      |> returns_json_header()
      |> returns_nested_data()
    end

    test "returns application ID", %{application_id: application_id} do
      assert %{"id" => _id} =
               "/applications/#{application_id}/finalize"
               |> path()
               |> patch!(Jason.encode!(@valid_body))
               |> parse_body()
               |> pluck_data
    end
  end
end
