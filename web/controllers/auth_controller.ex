defmodule Lunchclub.AuthController do
  @moduledoc """
  Auth controller responsible for handling Ueberauth responses
  """
  require Logger

  use Lunchclub.Web, :controller


  alias Ueberauth.Strategy.Helpers
  alias Lunchclub.User

  def request(conn, _params) do
    render(conn, "request.html", callback_url: Helpers.callback_url(conn))
  end

  def delete(conn, _params) do
    conn
    |> put_flash(:info, "You have been logged out!")
    |> configure_session(drop: true)
    |> redirect(to: "/")
  end


  def callback(conn, %{"code" => code}) do
    config = Application.get_env(:ueberauth, Ueberauth.Strategy.Google.OAuth)
    IO.inspect(config)
    client = OAuth2.Client.new(Keyword.merge([
      site: "https://localhost:4000",
      redirect_uri: "https://localhost:4000"
    ], config))
    client = OAuth2.Client.get_token!(client, code: code)
    resource = OAuth2.Client.get!(client, "https://www.googleapis.com/oauth2/v3/userinfo")
    IO.inspect(resource)
    # case UserFromAuth.get_info(auth) do
    #   {:ok, user_info} ->
    #     user = find_or_create(user_info)


    #     response = Guardian.Plug.api_sign_in(conn, user)
    #     jwt = Guardian.Plug.current_token(response)
    #     claims = get_claims(response)

    #     response
    #     |> put_resp_header("authorization", "Bearer #{jwt}")
    #     |> put_resp_header("x-expires", "#{claims["exp"]}")
    #     |> render("login.json", Map.merge(%{"user" => user, "jwt" => jwt}, claims))
    #   {:error, reason} ->
    #     IO.inspect(reason)
    #     conn
    #     |> put_status(401)
    #     |> render(Lunchclub.ErrorView, "401.json")
    # end
  end

  def unauthenticated(conn, params) do
    Logger.debug(inspect(params))
    conn
    |> put_status(401)
    |> render(Lunchclub.ErrorView, "401.json")
  end

  defp find_or_create(user_params) do
    case User |> where(provider_id: ^user_params.provider_id) |> Repo.one do
      nil -> insert_user(user_params)
      user -> IO.inspect(user)
    end
  end

  defp get_claims(conn) do
    case Guardian.Plug.claims(conn) do
      {:ok, claims} -> Map.take(claims, ["exp", "sub"])
      _ -> %{"exp" => "", "sub" => ""}
    end
  end

  defp insert_user(user_params) do
    changeset = User.changeset(%User{}, user_params)
    case Repo.insert(changeset) do
      {:ok, user} -> user
      {:error, reason} -> IO.inspect(reason)
    end
  end
end
