defmodule UrlShortener.EtsCacheTest do
  use ExUnit.Case
  doctest UrlShortener.EtsCache

  alias UrlShortener.EtsCache

  setup do
    {:ok, cache_process} = UrlShortener.EtsCache.start_link()
    {:ok, cache_process: cache_process}
  end

  test testdo

  end
end
