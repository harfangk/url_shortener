defmodule UrlShortener.Cache do
  use GenServer

  def start_link() do
    GenServer.start_link(__MODULE__, nil, name: :cache)
  end

  def insert_new_url_pair(shortened_url, full_url) do
    GenServer.cast(:cache, {:insert_new_url, shortened_url, full_url})
  end

  defp update_cache_priority(cache_table, kv_pair) do
    GenServer.cast(:cache, {:update_cache_priority, cache_table, kv_pair})
  end

  def handle_cast({:insert_new_url, shortened_url, full_url}, state) do
    :ets.insert(:high_priority, {shortened_url, full_url})
    Enum.each([:medium_priority, :low_priority], &update_cache_priority(&1, {shortened_url, full_url}))
    {:noreply, %{short_url: shortened_url, full_url: full_url}, state}
  end

  def handle_cast({:update_cache_priority, cache_table, {shortened_url, _} = kv_pair}, state) do
    :ets.delete(cache_table, shortened_url)
    :ets.insert(:high_priority, kv_pair)
    UrlShortener.CacheOwner.renew_cache_tables()
    {:noreply, state}
  end

  def lookup(:high_priority, shortened_url) do
    case :ets.lookup(:high_priority, shortened_url) do
      [{^shortened_url, full_url}] -> {:ok, {shortened_url, full_url}}
      _ -> lookup(:medium_priority, shortened_url)
    end
  end

  def lookup(:medium_priority, shortened_url) do
    case :ets.lookup(:medium_priority, shortened_url) do
      [{^shortened_url, full_url}] ->
        update_cache_priority(:medium_priority, {shortened_url, full_url})
        {:ok, {shortened_url, full_url}}
      _ -> lookup(:low_priority, shortened_url)
    end
  end
  
  def lookup(:low_priority, shortened_url) do
    case :ets.lookup(:low_priority, shortened_url) do
      [{^shortened_url, full_url}] ->
        update_cache_priority(:low_priority, {shortened_url, full_url})
        {:ok, {shortened_url, full_url}}
      _ -> {:error, "Full url to #{shortened_url} is not found in the database."}
    end
  end
end
