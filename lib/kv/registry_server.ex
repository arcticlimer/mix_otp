defmodule KV.RegistryServer do
  @moduledoc """
  Server for KV.Registry.

  This module is not meant to be manually used.
  """
  use GenServer

  @impl true
  def init(table) do
    names = :ets.new(table, [:named_table, read_concurrency: true])
    refs = %{}
    {:ok, {names, refs}}
  end

  def start_link(opts) do
    server = Keyword.fetch!(opts, :name)
    GenServer.start_link(__MODULE__, server, opts)
  end

  @doc """
  If a bucket with the given `name` do not exist,
  create another bucket with this name.
  """
  @impl true
  # Handle cast must be used for asynchronous requests
  # where the client do not care for the response.
  def handle_call({:create, name}, _from, {names, refs}) do
    case KV.Registry.lookup(names, name) do
      {:ok, _pid} ->
        {:noreply, {names, refs}}

      :error ->
        {:ok, pid} =
          DynamicSupervisor.start_child(
            KV.BucketSupervisor,
            KV.Bucket
          )

        ref = Process.monitor(pid)
        refs = Map.put(refs, ref, name)
        :ets.insert(names, {name, pid})
        {:reply, pid, {names, refs}}
    end
  end

  @doc """
  Removes a bucket from the storage when it crashes.
  """
  @impl true
  # Handle info must be used for cases that don't fit
  # handle_call or handle_cast, such as messages sent via send().
  def handle_info({:DOWN, ref, :process, _pid, _reason}, {names, refs}) do
    {name, refs} = Map.pop(refs, ref)
    :ets.delete(names, name)
    {:noreply, {names, refs}}
  end

  # Discards any unknown info
  @impl true
  def handle_info(_msg, state) do
    {:noreply, state}
  end
end
