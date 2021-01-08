defmodule KV.Registry do
  @moduledoc """
  Client API for KV.RegistryServer
  """

  @doc """
  Looks for a bucket of the given `name` stored in `server`.

  Returns `{:ok, pid}` if the bucket exists, `:error` otherwise.
  """
  def lookup(server, name) do
    GenServer.call(server, {:lookup, name})
  end

  @doc """
  Creates a bucket of the given `name` on the `server` if it not exists.
  """
  def create(server, name) do
    GenServer.cast(server, {:create, name})
  end
end
