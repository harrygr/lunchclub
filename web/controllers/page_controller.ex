defmodule Lunchclub.PageController do
  use Lunchclub.Web, :controller

  # plug Guardian.Plug.VerifySession
  # plug Guardian.Plug.EnsureAuthenticated, [handler: __MODULE__] when action in [:app]

  def index(conn, _params) do
    render conn, "index.html"
  end

  def app(conn, params) do
    case Guardian.decode_and_verify(conn.cookies["_token"]) do
      {:error, _reason} -> unauthenticated(conn, params)
      {:ok, claims} ->
        IO.inspect(claims)
        render conn, "app.html"
    end
  end

  def unauthenticated(conn, _params) do
    conn
    |> put_flash(:error, "You must be logged in to be here")
    |> redirect(to: "/")
  end
end
