defmodule Lunchclub.PageController do
  use Lunchclub.Web, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end

  def unauthenticated(conn, _params) do
    conn
    |> put_flash(:error, "You must be logged in to be here")
    |> redirect(to: "/")
  end
end
