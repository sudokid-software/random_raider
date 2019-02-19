defmodule RandomRaider.Repo do
  use Ecto.Repo,
    otp_app: :random_raider,
    adapter: Ecto.Adapters.Postgres
end
