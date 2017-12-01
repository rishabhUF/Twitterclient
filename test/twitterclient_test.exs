defmodule TwitterclientTest do
  use ExUnit.Case
  doctest Twitterclient

  test "greets the world" do
    assert Twitterclient.hello() == :world
  end
end
