defmodule UrlShortener.EtsCacheTest do
  use ExUnit.Case
  doctest UrlShortener.EtsCache

  alias UrlShortener.EtsCache

  test "should have cache tables running" do
    assert is_list :ets.info(:high_priority)
    assert is_list :ets.info(:medium_priority)
    assert is_list :ets.info(:low_priority)
  end

  test ":high_priority should be kept when its size is less than 3000" do
    :ets.delete_all_objects(:high_priority)
    initial_size = :ets.info(:high_priority)[:size]
    EtsCache.renew_cache_tables() 
    :sys.get_state(:ets_cache)
    later_size = :ets.info(:high_priority)[:size]
    assert initial_size == later_size
  end

  test ":high_priority should be reset when its size is more than 3000" do
    (1..3001)
    |> Enum.map(fn(x) -> :ets.insert(:high_priority, {x, x}) end)
    EtsCache.renew_cache_tables() 
    :sys.get_state(:ets_cache)
    assert :ets.info(:high_priority)[:size] == 0
  end
end
