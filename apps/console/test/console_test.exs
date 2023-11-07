defmodule ConsoleTest do
  use ExUnit.Case
  doctest Console

  test "greets the world" do
    assert Console.hello() == :world
  end
end
