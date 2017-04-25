defmodule UserFromAuth do
  @moduledoc """
  Retrieve the user information from an auth request
  """

  alias Ueberauth.Auth

  def get_info(%Auth{} = auth) do
    {:ok, basic_info(auth)}
  end

  defp basic_info(auth) do
    %{
      provider_id: auth.uid,
      provider: "google",
      email: auth.info.email,
      name: name_from_auth(auth),
      avatar: auth.info.image
    }
  end

  defp name_from_auth(auth) do
    if auth.info.name do
      auth.info.name
    else
      name = [auth.info.first_name, auth.info.last_name]
      |> Enum.filter(&(&1 != nil and &1 != ""))

      cond do
        length(name) == 0 -> auth.info.nickname
        true -> Enum.join(name, " ")
      end
    end
  end

  # defp validate_pass(%{other: %{password: ""}}) do
  #   {:error, "Password required"}
  # end
  # defp validate_pass(%{other: %{password: pw, password_confirmation: pw}}) do
  #   :ok
  # end
  # defp validate_pass(%{other: %{password: _}}) do
  #   {:error, "Passwords do not match"}
  # end
  # defp validate_pass(_), do: {:error, "Password Required"}
end