defmodule Lunchclub.Auth do

  alias Lunchclub.User
  alias Lunchclub.Repo

  def check(:google, token) do
    case Lunchclub.Auth.Strategy.Google.get("/oauth2/v3/tokeninfo?id_token=#{token}") do
      {:ok, %HTTPoison.Response{status_code: status_code, body: info}} when status_code in 200..399
        -> authenticate_user(:google, info)
      {:error, %HTTPoison.Error{reason: reason}} -> {:error, reason}
    end
  end

  def authenticate_user(:google, info) do
    config = Application.get_env(:lunchclub, Lunchclub.Auth.Google)

    # Ensure the token we got is for our app
    case String.equivalent?(info["aud"], config[:client_id]) do
      true -> {:ok, find_or_create(parse(:google, info))}
      false -> {:error, "Oauth2 Token not meant for this app"}
    end
  end

  defp parse(:google, info) do
    %{
      provider_id: info["sub"],
      provider: "google",
      email: info["email"],
      name: info["name"],
      avatar: info["picture"]
    }
  end

  defp find_or_create(user_params) do
    case Repo.get_by(User, provider_id: user_params.provider_id) do
      nil -> insert_user(user_params)
      user -> user
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