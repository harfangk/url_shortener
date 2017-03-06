defmodule UrlShortener.EtsCache do
  use GenServer

  def start_link() do
    GenServer.start_link(__MODULE__, nil, name: :ets_cache)
  end

  def init(_) do
    :ets.new(:high_priority, [:named_table])
    :ets.new(:medium_priority, [:named_table])
    :ets.new(:low_priority, [:named_table])
    {:ok, nil}
  end

  def lookup_full_url(shortened_url) do
    GenServer.call(:ets_cache, {:lookup_full_url, shortened_url})
  end

  def handle_call({:lookup_full_url, shortened_url}, _, state) do
    {:reply, lookup(:high_priority, shortened_url), state}
  end

  def insert_new_url(full_url) do
    GenServer.call(:ets_cache, {:insert_new_url, full_url})
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
        renew_cache_tables()
        {:ok, {shortened_url, full_url}}
      _ -> lookup(:low_priority, shortened_url)
    end
  end
  
  defp lookup(:low_priority, shortened_url) do
    case :ets.lookup(:low_priority, shortened_url) do
      [{^shortened_url, full_url}] ->
        update_cache_priority(:low_priority, {shortened_url, full_url})
        renew_cache_tables()
        {:ok, {shortened_url, full_url}}
      _ -> {:error, {"Full url not found", shortened_url}}
    end
  end

  defp update_cache_priority(cache_table, {shortened_url, full_url} = kv_pair) do
    :ets.delete(cache_table, shortened_url)
    :ets.insert(:high_priority, kv_pair)
  end

  defp renew_cache_tables() do
    if :ets.info(:high_priority)[:size] > 10000 do
      :ets.delete(:low_priority)
      :ets.rename(:medium_priority, :low_priority)
      :ets.rename(:high_priority, :medium_priority)
      :ets.new(:high_priority, [:named_table])
    end
  end
end
