defmodule UrlShortener.Web do
  use Plug.Router

  plug Plug.Parsers, parsers: [:json],
                     pass: ["application/json"],
                     json_decoder: Poison

  plug :match
  plug :dispatch

  get "/" do
    conn
    |> send_resp(200, "Url shortener microservice app. Refer to https://github.com/harfangk/url_shortener for further information.")
  end

  post "/new" do
    IO.inspect(conn)
    result = UrlShortener.create_short_url(conn.params)
    conn
    |> send_resp(200, "/new endpoint is reached")
  end

  match _ do
    conn
    |> send_resp(404, "This is not the page you are looking for.")
  end

  def start_link do
    {:ok, _} = Plug.Adapters.Cowboy.http(__MODULE__, [])
  end
end
