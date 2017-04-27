# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# General application configuration
config :lunchclub,
  ecto_repos: [Lunchclub.Repo]

config :lunchclub, Lunchclub.Auth.Google,
  client_id: System.get_env("GOOGLE_CLIENT_ID"),
  client_secret: System.get_env("GOOGLE_CLIENT_SECRET")

# Configures the endpoint
config :lunchclub, Lunchclub.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "CaSmgepCgbfO9sgZrGaXmCSc3sIDoz0znhduTWNJKWAhfPS9QwYFNaHgXqzsTaeR",
  render_errors: [view: Lunchclub.ErrorView, accepts: ~w(html json)],
  pubsub: [name: Lunchclub.PubSub,
           adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

config :guardian, Guardian,
  allowed_algos: ["HS512"], # optional
  verify_module: Guardian.JWT,  # optional
  issuer: "LunchClub",
  ttl: { 30, :days },
  allowed_drift: 2000,
  verify_issuer: true, # optional
  secret_key: "YgUaD9Y3TWSJN5EAoOprSt5BhMUDjY03bafIuBacKruCWdy84UNsvWArjxfWQsAB",
  serializer: Lunchclub.GuardianSerializer

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"
