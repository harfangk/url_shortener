defmodule UrlShortener.Base62Test do
  use ExUnit.Case
  doctest UrlShortener

  alias UrlShortener.Base62 

  test "encode input with non-binary value should raise ArgumentError" do
    assert_raise(ArgumentError, Base62.encode(35))
  end

  test "decode input with non-binary value should raise ArgumentError" do
    assert_raise(ArgumentError, Base62.decode(35))
  end

  test "encode 'https://www.google.com' should return 'cy'" do
    assert Base62.encode("https://www.google.com") == "cy"
  end

  test "decode 'LD' should return 'https://www.microsoft.com'" do
    assert Base62.decode("LD") == "https://www.microsoft.com"
  end

  test "encoding and decoding should be inverse function" do
    assert Base62.encode("https://www.facebook.com") |> Base62.decode() == "https://www.facebook.com"
    assert Base62.encode("KthXBai2") |> Base62.decode() == "KthXBai2"
  end
end
