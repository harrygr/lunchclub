defmodule Lunchclub.Repo.Migrations.CreateUser do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :email, :string
      add :provider_id, :string
      add :provider, :string
      add :name, :string
      add :avatar, :string

      timestamps()
    end

    create index(:users, [:email], unique: true)
    create index(:users, [:provider_id])
  end
end
