defmodule KV.RegistryServer do
  @moduledoc """
  Server for KV.Registry.

  This module is not meant to be manually used.
  """
  use GenServer

  @impl true
  def init(:ok) do
    names = %{}
    refs = %{}
    {:ok, {names, refs}}
  end

  def start_link(opts) do
    GenServer.start_link(__MODULE__, :ok, opts)
  end

  @doc """
  Searches for a bucket of the given `name`
  on the server buckets storage
  """
  @impl true
  # Handle call must be used for synchronous requests
  # where the client expects a response.
  def handle_call({:lookup, name}, _from, state) do
    {names, _} = state
    # The second tuple item is the response and
    # the third one is the new server state
    {:reply, Map.fetch(names, name), state}
  end

  @doc """
  If a bucket with the given `name` do not exist,
  create another bucket with this name.
  """
  @impl true
  # Handle cast must be used for asynchronous requests
  # where the client do not care for the response.
  def handle_cast({:create, name}, {names, refs}) do
    if Map.has_key?(names, name) do
      {:noreply, {names, refs}}
    else
      {:ok, bucket} = KV.Bucket.start_link([])
      # Take a reference to the bucket and stores it.
      ref = Process.monitor(bucket)
      refs = Map.put(refs, ref, name)
      names = Map.put(names, name, bucket)
      # The client don't receive or awaits for any cast,
      # so the second tuple element here is the new server state.
      {:noreply, {names, refs}}
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
    names = Map.delete(names, name)
    {:noreply, {names, refs}}
  end

  # Discards any unknown info
  @impl true
  def handle_info(_msg, state) do
    {:noreply, state}
  end
end
