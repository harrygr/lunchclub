defmodule Lunchclub.User do
  use Lunchclub.Web, :model

  schema "users" do
    field :email, :string
    field :provider_id, :string
    field :provider, :string
    field :name, :string
    field :avatar, :string

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:email, :provider_id, :provider, :name, :avatar])
    |> validate_required([:email, :provider, :avatar])
  end
end
