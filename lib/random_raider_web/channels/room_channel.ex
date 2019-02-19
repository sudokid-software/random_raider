defmodule RandomRaiderWeb.RoomChannel do
  use Phoenix.Channel

  def get_small_streamer(game_id, max_viewers) do
    client_id = Application.get_env(:random_raider, :twitch_client_id)
    url = "https://api.twitch.tv/helix/streams?game_id=511224&language=en&first=100&"
    cursor = HTTPoison.get!(url, [{"Client-ID", client_id}])
             |> Map.get(:body)
             |> Jason.decode!()
             |> Map.get("pagination")
             |> Map.get("cursor")

    get_small_streamer(game_id, max_viewers, cursor, :continue)
  end

  def get_small_streamer(game_id, max_viewers, cursor, :continue) do
    client_id = Application.get_env(:random_raider, :twitch_client_id)

    url = "https://api.twitch.tv/helix/streams?game_id=#{game_id}&language=en&first=100&after=#{cursor}"
    data = HTTPoison.get!(url, [{"Client-ID", client_id}])
                |> Map.get(:body)
                |> Jason.decode!()

    streamers = Enum.filter(Map.get(data, "data"), fn streamer -> Map.get(streamer, "viewer_count") <= max_viewers end)
    case Enum.fetch(streamers, 0) do
      :error -> 
        new_cursor = Map.get(data, "pagination") |> Map.get("cursor")
        get_small_streamer(game_id, max_viewers, new_cursor, :continue)
      {:ok, streamer} ->
        Map.get(streamer, "user_name")
    end
  end

  def join("room:lobby", _message, socket) do
    client_id = Application.get_env(:random_raider, :twitch_client_id)
    url = "https://api.twitch.tv/helix/games/top?first=6"
    game_list = HTTPoison.get!(url, [{"Client-ID", client_id}])
                |> Map.get(:body)
                |> Jason.decode!()
                |> Map.get("data")

    main_stream = Enum.fetch!(game_list, Enum.random(0..5))
                  |> Map.get("id")
                  |> get_small_streamer(10)

    # IO.puts("\n\nResponse: #{inspect(game_list)}\n\n")
    # url = "https://api.twitch.tv/helix/subscriptions?broadcaster_id=#{broadcaster_id}"
    # channel_details = HTTPoison.get!(url, [{"Client-ID", client_id}])
    # IO.puts("\n\nResponse: #{inspect(channel_details)}\n\n")

    data = %{
      counter: 0,
      stream: main_stream,
      next_stream: "2dheroes",
      prev_stream: "mrsmoothtv",
      supporters: [
        %{name: "PumpyLumpkin", type: "bits", bit_count: 50},
        %{name: "menatwork01", type: "sub"},
        %{name: "staghouse", type: "sub"},
        %{name: "lovemesenpai101", type: "sub"},
        %{name: "danandbeard", type: "sub_gift", to: "consol__log"},
        %{name: "danandbeard", type: "sub_gift", to: "javascriptfanboi"},
        %{name: "anony-mouse", type: "sub_gift", to: "mrdemonwolf"},
        %{name: "ABuffSeagull", type: "sub"},
        %{name: "PumpyLumpkin", type: "sub"}
      ],
      votes: %{
        "PumpyLumpkin"=> 100,
        "lovemesenpai101"=> 40,
        "staghouse"=> 20,
        "drathy"=> 10
      },
      games: game_list,
      viewer_count: RandomRaider.Services.ViewerCount.get_viewer_count()
    }
    {:ok, %{type: "join", data: data}, socket}
  end

  def join("room:" <> _private_room_id, _params, _socket) do
    {:error, %{reason: "unauthorized"}}
  end

  def handle_in("new_msg", %{"body" => body}, socket) do
    broadcast!(socket, "new_msg", %{body: body})
    {:noreply, socket}
  end
end

