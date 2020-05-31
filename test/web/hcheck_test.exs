defmodule Web.HcheckTest do
  use Support.ApiAcceptanceCase

  describe "[GET] 200 /hcheck" do
    test "endpoint behaviour" do
      "/hcheck"
      |> path()
      |> get!()
      |> returns_status(200)
    end
  end
end
