# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :random_raider,
  ecto_repos: [RandomRaider.Repo]

# Configures the endpoint
config :random_raider, RandomRaiderWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "pMen/yS5MFO3jELXh3eOtWkVKkT57I2qW4AErm+UpNLi5tShS4ZNXxcd1AsRQaS6",
  render_errors: [view: RandomRaiderWeb.ErrorView, accepts: ~w(json)],
  pubsub: [name: RandomRaider.PubSub, adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
