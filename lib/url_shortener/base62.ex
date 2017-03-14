defmodule UrlShortener.Base62 do
  @base62 ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9",
           "a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", "n", "o", "p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z",
           "A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z"]

  @moduledoc """
  Handle Base62 encoding of given string to shorter string. 
  Decoding is not implemented as it's unnecessary for 
  this application.
  """  
  @doc """
  Encode given string into shorter Base62 encoded string.
  Raise ArgumentError when the input is not string.
  ## Example
        iex> s = "wovon man nicht sprechen kann, darüber muss man schweigen"
        iex> UrlShortener.Base62.encode(s)
        "os1"
  """
  def encode(s) when is_binary(s) do
    s
    |> String.to_char_list()
    |> Enum.sum()
    |> encode_helper()
    |> List.to_string()
  end
  def encode(_), do: raise ArgumentError, "Encoding input should be string type"

  defp encode_helper(n) when n < 62, do: [Map.get(encoder_table(), n)]
  defp encode_helper(n) do
    [Map.get(encoder_table(), rem(n, 62)) | encode_helper(div(n, 62))]
  end

  defp encoder_table() do
    [Enum.to_list(0..61), @base62]
    |> List.zip()
    |> Map.new()
  end
end
