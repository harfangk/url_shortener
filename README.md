# UrlShortener

A simple Url Shortener toy app written in Elixir for new Elixir learners to
take a look at. 

It consists of six modules:
* `UrlShortener`: holds public functions for interfacing with this application
* `Application`: holds supervision tree for the application
* `Base62`: transforms full urls into shortened urls using custom base62
  encoding
* `EtsCache`: contains three `ETS` tables for storage purpose in a `GenServer`
  process
* `EtsCache.Interface`: provides functions for interacting with `EtsCache` 
* `Web`: provides web interface for this application using `Cowboy`

There are basic tests and doctests for public functions of each module. 

# How to Use

This application uses JSON API format, so all requests should follow that.

## `/new` 

This route takes HTTP POST request formatted like:

```json
{
  "data": [
            {"url": "http://elixir-lang.org/"}
          ]
}
```

And returns: 

```json
{
  "data": [
            {"shortened_url":"ty","full-url": "http://elixir-lang.org/"}
          ]
}
```

## `/:shortened_url`

This route takes HTTP GET request with shortened url in the address.

`/ty` returns:

```json
{
  "data": [
            {"shortened_url":"ty","full-url": "http://elixir-lang.org/"}
          ]
}
```
