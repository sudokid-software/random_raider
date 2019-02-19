defmodule RandomRaiderWeb.Router do
  use RandomRaiderWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api", RandomRaiderWeb do
    pipe_through :api
  end
end
