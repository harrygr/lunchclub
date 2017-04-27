defmodule Lunchclub.AuthController do
  @moduledoc """
  Auth controller responsible for handling Ueberauth responses
  """
  use Lunchclub.Web, :controller

  alias Lunchclub.User

  def callback(conn, %{"code" => code}) do
    case Lunchclub.Auth.check(:google, code) do
      {:ok, user} -> authenticate_user(conn, user)
      {:error, %HTTPoison.Error{reason: reason}} -> unauthenticated(conn, reason)
      {:error, reason} -> unauthenticated(conn, reason)
    end
  end

  def unauthenticated(conn, _reason) do
    conn
    |> put_status(401)
    |> render(Lunchclub.ErrorView, "401.json")
  end

  defp authenticate_user(conn, user) do
    response = Guardian.Plug.api_sign_in(conn, user)
    jwt = Guardian.Plug.current_token(response)
    claims = get_claims(response)

    response
    |> put_resp_header("authorization", "Bearer #{jwt}")
    |> put_resp_header("x-expires", "#{claims["exp"]}")
    |> render("token.json", Map.merge(%{"user" => user, "jwt" => jwt}, claims))
  end

  defp get_claims(conn) do
    case Guardian.Plug.claims(conn) do
      {:ok, claims} -> Map.take(claims, ["exp", "sub"])
      _ -> %{"exp" => "", "sub" => ""}
    end
  end
end
