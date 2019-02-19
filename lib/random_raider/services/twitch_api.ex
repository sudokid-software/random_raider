defmodule RandomRaider.Services.TwitchApi do
  use GenServer

  def start_link(_) do
    GenServer.start_link(__MODULE__, %{})
  end

  def init(_) do
    :pg2.create(:twitch_api)
    :pg2.join(:twitch_api, self())
    {:ok, get_token()}
  end

  def get_token() do
    client_id = Application.get_env(:random_raider, :twitch_client_id)
    url = "https://id.twitch.tv/oauth2/token"
    json = Jason.encode!(%{
      "client_id"=> client_id,
      "client_secret"=> Application.get_env(:random_raider, :twitch_client_secret),
      "grant_type"=> "client_credentials",
      "scope"=> "channel:read:subscriptions"
    })
    HTTPoison.post!(url, json, [{"Content-Type", "application/json"}])
    |> Map.get(:body)
    |> Jason.decode!()
  end

  def handle_call(:subscriptions, _from, state) do
    response = Map.get(state, "access_token")
               |> get_subscriptions()
    {:reply, response, state}
  end

  def handle_cast(:start, state) do
    {:noreply, state}
  end

  def handle_info(:work, state) do
    {:noreply, state}
  end

  def get_viewer_count(user_id) do
    client_id = Application.get_env(:random_raider, :twitch_client_id)
    url = "https://api.twitch.tv/helix/streams?user_id=#{user_id}"
    data = HTTPoison.get!(url, [{"Client-ID", client_id}])
    |> Map.get(:body)
    |> Jason.decode!()
    |> Map.get("data")
    |> Enum.fetch!(0)
    |> Map.get("viewer_count")
  end

  def get_subscriptions(token) do
    user_id = Application.get_env(:random_raider, :twitch_broadcaster_id)
    client_id = Application.get_env(:random_raider, :twitch_client_id)

    url = "https://api.twitch.tv/helix/subscriptions?broadcaster_id=#{user_id}"
    channel_details = HTTPoison.get!(url, [{"Client-ID", client_id}, {"Authorization", "Bearer " <> token}])
    IO.puts("\n\nResponse: #{inspect(channel_details)}\n\n")
    channel_details
  end
end

