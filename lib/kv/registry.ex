defmodule KV.Registry do
  @moduledoc """
  Client API for KV.RegistryServer
  """

  @doc """
  Starts the registry.
  """
  def start_link(opts) do
    KV.RegistryServer.start_link(opts)
  end

  @doc """
  Looks for a bucket of the given `name` stored in `server`.

  Returns `{:ok, pid}` if the bucket exists, `:error` otherwise.
  """
  def lookup(server, name) do
    case :ets.lookup(server, name) do
      [{^name, pid}] -> {:ok, pid}
      [] -> :error
    end
  end

  @doc """
  Creates a bucket of the given `name` on the `server` if it not exists.
  """
  def create(server, name) do
    GenServer.call(server, {:create, name})
  end
end
