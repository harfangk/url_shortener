defmodule UrlShortener do
  @moduledoc """
  This is the public interface for UrlShortener. It provides two functions for
  interacting with the app:
  * create_short_url/1
  * lookup_full_url/1
  Both the request and response follow the JSON API format.
  """

  @doc """
  Create shortened url of the given full url, store the pair in ETS table, then 
  respond with the pair of shortened url and full url.
  Both the request and response are in JSON API format and need some wrapper JSON keys.
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
                                               detail: "Url should be submitted under the url key"
                                             }
                                           ]}, [])
        {:error, response}
    end
  end

  @doc """
  Lookup the full url of the given shortened_url. 
  Both the request and response are in JSON API format and need some wrapper JSON keys.
  """
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
