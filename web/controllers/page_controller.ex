defmodule Lunchclub.PageController do
  use Lunchclub.Web, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end
end
