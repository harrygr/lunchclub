defmodule Lunchclub.UserTest do
  use Lunchclub.ModelCase

  alias Lunchclub.User

  @valid_attrs %{avatar: "some content", email: "some content", first_name: "some content", last_name: "some content", provider: "some content"}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = User.changeset(%User{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = User.changeset(%User{}, @invalid_attrs)
    refute changeset.valid?
  end
end
