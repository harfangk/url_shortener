defmodule UrlShortener.Router do
  use Plug.Router

  plug :match
  plug :dispatch

  get "/" do
    conn
    |> send_resp(200, "Root")
  end

  match _ do
    conn
    |> send_resp(404, "This is not the page you are looking for.")
  end

  def start_link do
    {:ok, _} = Plug.Adapters.Cowboy.http(UrlShortener.Router, [])
  end
end
