defmodule Lunchclub.AuthController do
  @moduledoc """
  Auth controller responsible for handling Ueberauth responses
  """

  use Lunchclub.Web, :controller
  plug Ueberauth

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

  def callback(%{assigns: %{ueberauth_failure: _fails}} = conn, _params) do
    conn
    |> put_flash(:error, "Failed to authenticate.")
    |> redirect(to: "/")
  end

  def callback(%{assigns: %{ueberauth_auth: auth}} = conn, _params) do
    case UserFromAuth.find_or_create(auth) do
      {:ok, user} ->
        registered_user = find_or_create(user)
        IO.inspect(registered_user)
        conn
        |> put_flash(:info, "Successfully authenticated.")
        |> redirect(to: "/")
      {:error, reason} ->
        conn
        |> put_flash(:error, reason)
        |> redirect(to: "/")
    end
  end

  defp find_or_create(user_params) do
    IO.inspect(user_params)
    case User |> where(provider_id: ^user_params.provider_id) |> Repo.one do
      nil -> insert_user(user_params)
      user -> IO.inspect(user)
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