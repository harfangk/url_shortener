defmodule UrlShortener.EtsCache.Interface do
  use GenServer

  @moduledoc """
  Handles the interface to ETS cache storage system. Supports two operations:
  * insert new url pair
  * lookup the full url given a shortened url
  Every time a new record is created or a record is accessed, it is moved to
  high_priority table to store it longer. 
  """

  def start_link() do
    GenServer.start_link(__MODULE__, nil, name: :ets_cache_interface)
  end

  @doc """
  Insert a new pair of shortened and full urls. Use gen_server cast to ensure
  there's only one process that handles writing operation.
  """
  def insert_new_url_pair({shortened_url, full_url}) do
    GenServer.cast(:ets_cache_interface, {:insert_new_url, {shortened_url, full_url}})
  end

  defp update_cache_priority(cache_table, kv_pair) do
    GenServer.cast(:ets_cache_interface, {:update_cache_priority, cache_table, kv_pair})
  end

  def handle_cast({:insert_new_url, {shortened_url, full_url}}, state) do
    :ets.insert(:high_priority, {shortened_url, full_url})
    Enum.each([:medium_priority, :low_priority], &update_cache_priority(&1, {shortened_url, full_url}))
    {:noreply, state}
  end

  def handle_cast({:update_cache_priority, cache_table, {shortened_url, _} = kv_pair}, state) do
    :ets.delete(cache_table, shortened_url)
    :ets.insert(:high_priority, kv_pair)
    UrlShortener.EtsCache.renew_cache_tables()
    {:noreply, state}
  end

  @doc """
  Look up a full url of the given shortened url. It searches through the tables
  from high to low priority iteratively. Lookup operation can be called from 
  multiple processes. 
  """
  def lookup(shortened_url) do
    case :ets.lookup(:high_priority, shortened_url) do
      [{^shortened_url, full_url}] -> {:ok, {shortened_url, full_url}}
      _ -> lookup(:medium_priority, shortened_url)
    end
  end

  defp lookup(:medium_priority, shortened_url) do
    case :ets.lookup(:medium_priority, shortened_url) do
      [{^shortened_url, full_url}] ->
        update_cache_priority(:medium_priority, {shortened_url, full_url})
        {:ok, {shortened_url, full_url}}
      _ -> lookup(:low_priority, shortened_url)
    end
  end
  
  defp lookup(:low_priority, shortened_url) do
    case :ets.lookup(:low_priority, shortened_url) do
      [{^shortened_url, full_url}] ->
        update_cache_priority(:low_priority, {shortened_url, full_url})
        {:ok, {shortened_url, full_url}}
      _ -> {:error, "Full url to #{shortened_url} is not found in the database."}
    end
  end
end
