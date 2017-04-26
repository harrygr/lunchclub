defmodule Lunchclub.Auth do
  @moduledoc """
  Creates `Ueberauth.Auth` structs from OAuth responses.

  This module is an ugly hack which is necessary because `Ueberauth` doesn't provide
  the necessary hooks to get such a struct without giving it control of the whole
  callback phase. We can't do this in the API because all the mobile app can give us
  is the OAuth token.

  Most of the code was lifted from Ueberauth, with minor changes as needed.
  """

  def new(type, token, secret \\ nil)
  def new(:facebook, token, _secret) do
    {_module, config} = Application.get_env(:ueberauth, Ueberauth)[:providers][:facebook]
    client = Ueberauth.Strategy.Facebook.OAuth.client
    token = OAuth2.AccessToken.new(token, client)

    case OAuth2.AccessToken.get(token, "/me?fields=#{config[:profile_fields]}") do
      {:ok, %OAuth2.Response{status_code: status_code, body: user}} when status_code in 200..399 ->
        {:ok, parse(:facebook, user, token)}
      {:ok, %OAuth2.Response{status_code: 401}} ->
        {:error, "Not authorized."}
      {:error, %OAuth2.Error{reason: reason}} ->
        {:error, reason}
      _other ->
        {:error, "An unknown error occurred."}
    end
  end

  def new(:twitter, token, secret) do
    params = [include_entities: false, skip_status: true, include_email: true]

    case Ueberauth.Strategy.Twitter.OAuth.get("/1.1/account/verify_credentials.json", params, {token, secret}) do
      {:ok, {{_, status_code, _}, _, body}} when status_code in 200..399 ->
        user =
          body
          |> List.to_string
          |> Poison.decode!

        {:ok, parse(:twitter, user, {token, secret})}
      {:ok, {{_, 401, _}, _, _}} ->
        {:error, "Not authorized."}
      {:ok, {_, _, body}} ->
        body =
          body
          |> List.to_string
          |> Poison.decode!

        error = List.first(body["errors"])
        {:error, error}
    end
  end

  def new(:google, token, _secret) do
    client = Ueberauth.Strategy.Google.OAuth.client
    token = OAuth2.Client.get_token(client, code: token)
    IO.inspect(token)
    case OAuth2.Client.get(token, "https://www.googleapis.com/oauth2/v3/userinfo") do
      {:ok, %OAuth2.Response{status_code: status_code, body: user}} when status_code in 200..399 ->
        {:ok, parse(:google, user, token)}
      {:ok, %OAuth2.Response{status_code: 401, body: _body}} ->
        {:error, "Not authorized."}
      {:error, %OAuth2.Error{reason: reason}} ->
        {:error, reason}
    end
  end

  defp parse(:facebook, user, token) do
    scopes = token.other_params["scope"] || ""
    scopes = String.split(scopes, ",")

    %Ueberauth.Auth{
      provider: :facebook,
      strategy: Ueberauth.Strategy.Facebook,
      uid: user["id"],
      info: %Ueberauth.Auth.Info{
        description: user["bio"],
        email: user["email"],
        first_name: user["first_name"],
        image: "http://graph.facebook.com/#{user["id"]}/picture?type=square",
        last_name: user["last_name"],
        name: user["name"],
        urls: %{
          facebook: user["link"],
          website: user["website"]
        }
      },
      extra: %Ueberauth.Auth.Extra{
        raw_info: %{
          token: token,
          user: user
        }
      },
      credentials: %Ueberauth.Auth.Credentials{
        expires: token.expires_at != nil,
        expires_at: token.expires_at,
        scopes: scopes,
        token: token.access_token
      }
    }
  end

  defp parse(:twitter, user, {token, secret}) do
    %Ueberauth.Auth{
      provider: :twitter,
      strategy: Ueberauth.Strategy.Twitter,
      uid: user["id_str"],
      info: %Ueberauth.Auth.Info{
        email: user["email"],
        image: user["profile_image_url"],
        name: user["name"],
        nickname: user["screen_name"],
        description: user["description"],
        urls: %{
          Twitter: "https://twitter.com/#{user["screen_name"]}",
          Website: user["url"]
        }
      },
      extra: %Ueberauth.Auth.Extra{
        raw_info: %{
          token: token,
          user: user
        }
      },
      credentials: %Ueberauth.Auth.Credentials{
        token: token,
        secret: secret
      }
    }
  end

  defp parse(:google, user, token) do
    scopes = String.split(token.other_params["scope"] || "", ",")

    %Ueberauth.Auth{
      provider: :google,
      strategy: Ueberauth.Strategy.Google,
      uid: user["sub"],
      info: %Ueberauth.Auth.Info{
        email: user["email"],
        first_name: user["given_name"],
        image: user["picture"],
        last_name: user["family_name"],
        name: user["name"],
        urls: %{
          profile: user["profile"],
          website: user["hd"]
        }
      },
      extra: %Ueberauth.Auth.Extra{
        raw_info: %{
          token: token,
          user: user
        }
      },
      credentials: %Ueberauth.Auth.Credentials{
        expires: token.expires_at != nil,
        expires_at: token.expires_at,
        scopes: scopes,
        refresh_token: token.refresh_token,
        token: token.access_token
      }
    }
  end
end