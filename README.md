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

## Heroku Deployment

