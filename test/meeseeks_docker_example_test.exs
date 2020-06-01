defmodule MeeseeksDockerExampleTest do
  use ExUnit.Case
  doctest MeeseeksDockerExample

  test "greets the world" do
    assert MeeseeksDockerExample.hello() == :world
  end
end
