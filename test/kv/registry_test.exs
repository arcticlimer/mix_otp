defmodule KV.RegistryTest do
  use ExUnit.Case, async: true

  setup context do
    start_supervised!({KV.RegistryServer, name: context.test})
    %{server: context.test}
  end

  test "spawns buckets", %{server: server} do
    assert KV.Registry.lookup(server, "shopping") == :error
    KV.Registry.create(server, "shopping")
    assert {:ok, _bucket} = KV.Registry.lookup(server, "shopping")
  end

  test "removes buckets on exit", %{server: server} do
    KV.Registry.create(server, "house")
    {:ok, bucket} = KV.Registry.lookup(server, "house")

    Agent.stop(bucket)
    # Do a call to ensure the registry processed the DOWN message
    KV.Registry.create(server, "bogus")
    assert KV.Registry.lookup(server, "house") == :error
  end

  test "removes bucket on crash", %{server: server} do
    KV.Registry.create(server, "shopping")
    {:ok, bucket} = KV.Registry.lookup(server, "shopping")

    Agent.stop(bucket, :shutdown)
    # Do a call to ensure the registry processed the DOWN message
    KV.Registry.create(server, "bogus")
    assert KV.Registry.lookup(server, "shopping") == :error
  end

  test "bucket can crash at any time", %{server: server} do
    KV.Registry.create(server, "shopping")
    {:ok, bucket} = KV.Registry.lookup(server, "shopping")

    Agent.stop(bucket, :shutdown)
    catch_exit(KV.Bucket.put(bucket, "banana", 39))
  end
end
