defmodule UrlShortener.Cache do
  use GenServer

  def start_link() do
    GenServer.start_link(__MODULE__, nil, name: :cache)
  end

  def lookup_full_url(shortened_url) do
    lookup(:high_priority, shortened_url)
  end

  def insert_new_url(full_url) do
    GenServer.call(:cache, {:insert_new_url, full_url})
  end

  def handle_call({:insert_new_url, full_url}, _, state) do
    shortened_url = UrlShortener.Base62.encode(full_url)
    :ets.insert(:high_priority, {shortened_url, full_url})
    Enum.each([:medium_priority, :low_priority], &update_cache_priority(&1, {shortened_url, full_url}))
    {:reply, {shortened_url, full_url}, state}
  end

  defp lookup(:high_priority, shortened_url) do
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
      _ -> {:error, {"Full url not found", shortened_url}}
    end
  end

  defp update_cache_priority(cache_table, kv_pair) do
    GenServer.cast(:cache, {:update_cache_priority, cache_table, kv_pair})
  end

  def handle_cast({:update_cache_priority, cache_table, {shortened_url, _} = kv_pair}, state) do
    :ets.delete(cache_table, shortened_url)
    :ets.insert(:high_priority, kv_pair)
    UrlShortener.CacheOwner.renew_cache_tables()
    {:noreply, state}
  end
end
