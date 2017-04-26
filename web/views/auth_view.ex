  defmodule Lunchclub.AuthView do
    def render("token.json", conn) do
      %{
        user: Lunchclub.UserView.user_json(conn["user"]),
        jwt: conn["jwt"],
        exp: conn["exp"],
        sub: conn["sub"]
      }
    end
  end