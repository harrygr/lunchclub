defmodule Lunchclub.Router do
  use Lunchclub.Web, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :spa do
    plug :put_layout, false
    plug :accepts, ["html"]
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  pipeline :api_auth do
    plug Guardian.Plug.VerifyHeader, realm: "Bearer"
    plug Guardian.Plug.LoadResource
  end

  scope "/auth", Lunchclub do
    pipe_through [:api]

    # get "/:provider", AuthController, :request
    get "/:provider/callback", AuthController, :callback
    post "/:provider/callback", AuthController, :callback
    # delete "/logout", AuthController, :delete
  end

  scope "/", Lunchclub do
    pipe_through :spa # Use the SPA browser stack

    get "/", PageController, :index
    get "/*path", PageController, :index
  end

  scope "/api", Lunchclub do
    pipe_through [:api, :api_auth]

    get "/profile", UserController, :profile
  end

  # Other scopes may use custom stacks.
  # scope "/api", Lunchclub do
  #   pipe_through :api
  # end
end
