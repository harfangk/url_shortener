defmodule UrlShortener.Web do
  use Plug.Router
  use Plug.Debugger
  use Plug.ErrorHandler

  plug Plug.Parsers, parsers: [:json],
                     pass: ["application/vnd.api+json"],
                     json_decoder: Poison

  plug :match
  plug :dispatch

  get "/" do
    conn
    |> send_resp(200, "Url shortener microservice app. Refer to https://github.com/harfangk/url_shortener for further information.")
  end

  get "/:shortened_url" do
    result = UrlShortener.lookup_full_url(conn.params)
    case result do
      {:ok, response} ->
        conn
        |> put_resp_header("Content-Type", "application/vnd.api+json")
        |> send_resp(200, response)
      {:error, response} ->
        conn
        |> put_resp_header("Content-Type", "application/vnd.api+json")
        |> send_resp(400, response)
    end
    conn
    |> send_resp(200, "Yeah")
  end

  post "/new" do
    result = UrlShortener.create_short_url(conn.params)
    case result do
      {:ok, response} ->
        conn
        |> put_resp_header("Content-Type", "application/vnd.api+json")
        |> send_resp(200, response)
      {:error, response} ->
        conn
        |> put_resp_header("Content-Type", "application/vnd.api+json")
        |> IO.inspect()
        |> send_resp(400, response)
    end
  end

  match _ do
    conn
    |> send_resp(404, "This is not the page you are looking for.")
  end

  def start_link do
    {:ok, _} = Plug.Adapters.Cowboy.http(__MODULE__, [])
  end

  def handle_errors(conn, %{kind: _kind, reason: _reason, stack: _stack}) do
    send_resp(conn, 400, "Something went wrong")
  end
end
