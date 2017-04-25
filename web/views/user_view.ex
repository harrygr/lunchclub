defmodule Lunchclub.UserView do
  use Lunchclub.Web, :view

  def render("index.json", %{users: users}) do
    %{data: render_many(users, Lunchclub.UserView, "user.json")}
  end

  def render("show.json", %{user: user}) do
    %{data: render_one(user, Lunchclub.UserView, "user.json")}
  end

  def render("user.json", %{user: user}) do
    %{id: user.id,
      email: user.email,
      provider: user.provider,
      name: user.name,
      avatar: user.avatar}
  end
end
