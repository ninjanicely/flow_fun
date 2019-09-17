defmodule FlowFunTest do
  use ExUnit.Case
  doctest FlowFun

  test "greets the world" do
    assert FlowFun.hello() == :world
  end
end
