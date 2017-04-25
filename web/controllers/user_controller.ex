defmodule Lunchclub.UserController do
  use Lunchclub.Web, :controller

  alias Lunchclub.User
  plug Guardian.Plug.EnsureAuthenticated, [handler: Lunchclub.AuthController]

  def profile(conn, _params) do
    user = Guardian.Plug.current_resource(conn)

    render(conn, "show.json", user: user)
  end
end
