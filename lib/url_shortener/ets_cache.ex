defmodule UrlShortener.EtsCache do
  use GenServer
  @maximum_size 3000

  @moduledoc """
  This process owns three ETS tables used for storage purpose.
  It is also responsible for limiting the maximum size of
  ETS tables. 
  """

  def start_link() do
    GenServer.start_link(__MODULE__, nil, name: :ets_cache)
  end

  def init(_) do
    :ets.new(:high_priority, [:named_table, :public])
    :ets.new(:medium_priority, [:named_table, :public])
    :ets.new(:low_priority, [:named_table, :public])

    {:ok, nil}
  end

  @doc """
  Call this operation to ensure that the maximum number of stored objects
  remain three times the @maximum_size set in the module.
  """
  def renew_cache_tables() do
    GenServer.cast(:ets_cache, {:renew_cache_tables})
  end

  def handle_cast({:renew_cache_tables}, state) do
    if :ets.info(:high_priority)[:size] > @maximum_size do
      :ets.delete(:low_priority)
      :ets.rename(:medium_priority, :low_priority)
      :ets.rename(:high_priority, :medium_priority)
      :ets.new(:high_priority, [:named_table, :public])
    end
    {:noreply, state}
  end
end
