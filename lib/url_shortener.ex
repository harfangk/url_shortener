defmodule UrlShortener do
  @moduledoc """
  Documentation for UrlShortener.
  """

  @doc """
  Hello world.

  ## Examples

      iex> UrlShortener.hello
      :world

  """
  def create_short_url(input) do
    case input do
      %{"url" => full_url} -> 
        shortened_url = UrlShortener.Base62.encode(full_url)
        UrlShortener.Cache.insert_new_url_pair(shortened_url, full_url)
        {:ok, Poison.Encoder.encode(%{shortened_url: shortened_url, full_url: full_url}, [])}
      _ -> {:error, "Incorrect input format. Please check the documentation."}
    end
  end
end
