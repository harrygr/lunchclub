defmodule Lunchclub.Auth.Strategy.Google do
  use HTTPoison.Base

  @expected_fields ~w(
    sub aud iss email name picture iat exp
  )

  def process_url(url) do
    "https://www.googleapis.com" <> url
  end

  def process_response_body(body) do
    body
    |> Poison.decode!
    |> Map.take(@expected_fields)
  end

  defp basic_info(auth) do
    %{
      provider_id: auth["sub"],
      provider: "google",
      email: auth["email"],
      name: auth["name"],
      avatar: auth["picture"]
    }
  end
end