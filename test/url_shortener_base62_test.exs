defmodule UrlShortener.Base62Test do
  use ExUnit.Case, async: true
  doctest UrlShortener.Base62

  alias UrlShortener.Base62 

  test "encode input with non-binary value should raise ArgumentError" do
    assert_raise ArgumentError, fn ->
      Base62.encode(35)
    end
  end

  test "encode 'https://www.google.com' should return 'cy'" do
    assert Base62.encode("https://www.google.com") == "cy"
  end
end
