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
      %{"data" => [%{"url" => full_url}]} -> 
        shortened_url = UrlShortener.Base62.encode(full_url)
        UrlShortener.EtsCache.Interface.insert_new_url_pair({shortened_url, full_url})
        response = Poison.Encoder.encode(%{data: [
                                             %{shortened_url: shortened_url, full_url: full_url}
                                           ]}, [])
        {:ok, response}
      _ ->
        response = Poison.Encoder.encode(%{errors: [
                                             %{status: 400,
                                               source: %{pointer: "/data/url"},
                                               title: "Invalid Key",
                                               detail: "Url should be sent in url key"
                                             }
                                           ]}, [])
        {:error, response}
    end
  end

  def lookup_full_url(%{"shortened_url" => shortened_url}) do
    case UrlShortener.EtsCache.Interface.lookup(shortened_url) do
      {:ok, {shortened_url, full_url}} ->
        response = Poison.Encoder.encode(%{data: [
                                             %{shortened_url: shortened_url, full_url: full_url}
                                           ]}, [])
        {:ok, response}
      {:error, message} ->
        response = Poison.Encoder.encode(%{errors: [
                                             %{status: 404,
                                               source: %{pointer: "/data/url"},
                                               title: "URL not found",
                                               detail: message
                                             }
                                           ]}, [])
        {:error, response}
    end
  end
end
