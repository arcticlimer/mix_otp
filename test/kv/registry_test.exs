defmodule KV.RegistryTest do
  use ExUnit.Case, async: true

  setup do
    server = start_supervised!(KV.RegistryServer)
    %{server: server}
  end

  test "spawns buckets", %{server: server} do
    assert KV.Registry.lookup(server, "shopping") == :error
    KV.Registry.create(server, "shopping")
    assert {:ok, bucket} = KV.Registry.lookup(server, "shopping")
  end

  test "removes buckets on exit", %{server: server} do
    KV.Registry.create(server, "house")
    {:ok, bucket} = KV.Registry.lookup(server, "house")
    Agent.stop(bucket)
    assert KV.Registry.lookup(server, "house") == :error
  end
end
