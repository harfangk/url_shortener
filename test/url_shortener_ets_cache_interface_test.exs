defmodule UrlShortener.EtsCache.InterfaceTest do
  use ExUnit.Case
  doctest UrlShortener.EtsCache.Interface

  alias UrlShortener.EtsCache.Interface

  setup do
    :ets.delete_all_objects(:high_priority)
    :ets.delete_all_objects(:medium_priority)
    :ets.delete_all_objects(:low_priority)
    url_pair = {"key", "value"}
    {:ok, url_pair: url_pair}
  end

  test "new url pair should be inserted into :high_priority table", %{url_pair: url_pair} do
    assert [] = :ets.lookup(:high_priority, "key")
    Interface.insert_new_url_pair(url_pair)
    :sys.get_state(:ets_cache_interface)
    assert [^url_pair] = :ets.lookup(:high_priority, "key")
  end

  test "existing url pair should be moved to :high_priority table", %{url_pair: url_pair} do
    cache_table = :low_priority
    :ets.insert(cache_table, url_pair)
    assert [] = :ets.lookup(:high_priority, "key")
    assert [^url_pair] = :ets.lookup(:low_priority, "key")
    Interface.update_cache_priority(cache_table, url_pair)
    :sys.get_state(:ets_cache_interface)
    assert [^url_pair] = :ets.lookup(:high_priority, "key")
    assert [] = :ets.lookup(:low_priority, "key")
  end

  test "looking up existing url pair in :high_priority should return it", %{url_pair: {key, _} = url_pair} do
    :ets.insert(:high_priority, url_pair)
    :sys.get_state(:ets_cache_interface)
    assert {:ok, ^url_pair} = Interface.lookup(key)
  end

  test "looking up existing url pair in :low_priority should return it and move it", %{url_pair: {key, _} = url_pair} do
    :ets.insert(:low_priority, url_pair)
    assert {:ok, ^url_pair} = Interface.lookup(key)
    :sys.get_state(:ets_cache_interface)
    assert [] = :ets.lookup(:low_priority, key)
  end

  test "looking up non-existing url pair should return error", %{url_pair: {key, _}} do
    assert {:error, _} = Interface.lookup(key)
  end
end
