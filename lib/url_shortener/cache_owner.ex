defmodule UrlShortener.CacheOwner do
  use GenServer

  def start_link() do
    GenServer.start_link(__MODULE__, nil, name: :cache_owner)
  end

  def init(_) do
    :ets.new(:high_priority, [:named_table, :public])
    :ets.new(:medium_priority, [:named_table, :public])
    :ets.new(:low_priority, [:named_table, :public])

    {:ok, nil}
  end

  def renew_cache_tables() do
    GenServer.cast(:cache_owner, {:renew_cache_tables})
  end

  def handle_cast({:renew_cache_tables}, state) do
    if :ets.info(:high_priority)[:size] > 3000 do
      :ets.delete(:low_priority)
      :ets.rename(:medium_priority, :low_priority)
      :ets.rename(:high_priority, :medium_priority)
      :ets.new(:high_priority, [:named_table, :public])
    end
    {:noreply, state}
  end
end
