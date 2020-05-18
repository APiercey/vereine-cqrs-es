defmodule VereineTest do
  use ExUnit.Case
  doctest Vereine

  test "greets the world" do
    assert Vereine.hello() == :world
  end
end
