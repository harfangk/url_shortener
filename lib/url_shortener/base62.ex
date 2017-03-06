defmodule UrlShortener.Base62 do
  @base62 ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9",
           "a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", "n", "o", "p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z",
           "A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z"]

  def encode(s) do
    s
    |> String.to_char_list()
    |> Enum.sum()
    |> encode_helper()
    |> List.to_string()
  end

  defp encode_helper(n) when n < 62, do: [Map.get(encoder_table(), n)]
  defp encode_helper(n) do
    [Map.get(encoder_table(), rem(n, 62)) | encode_helper(div(n, 62))]
  end

  def decode(s) do
    s_converted_to_int_list = for <<x :: utf8 <- s>> do
      Map.get(decoder_table(), <<x :: utf8>>)
    end

    List.zip([s_converted_to_int_list, Enum.to_list(0..byte_size(s))])
    |> Enum.map(fn {coefficient, power} -> coefficient * (:math.pow(62, power)) end)
    |> Enum.sum()
    |> round()
  end

  defp encoder_table() do
    [Enum.to_list(0..61), @base62]
    |> List.zip()
    |> Map.new()
  end
  
  defp decoder_table() do
    [@base62, Enum.to_list(0..61)]
    |> List.zip()
    |> Map.new()
  end
end
