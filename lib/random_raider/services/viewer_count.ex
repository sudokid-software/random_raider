defmodule RandomRaider.Services.ViewerCount do
  use GenServer

  def start_link(_) do
    GenServer.start_link(__MODULE__, %{})
  end

  def init(state) do
    schedule_work()
    {:ok, state}
  end

  def handle_cast(:start, state) do
    {:noreply, state}
  end

  def handle_info(:work, state) do
    schedule_work()
    {:noreply, state}
  end

  def get_viewer_count() do
    user_id = Application.get_env(:random_raider, :twitch_broadcaster_id)
    RandomRaider.Services.TwitchApi.get_viewer_count(user_id)
  end

  defp schedule_work() do
    RandomRaiderWeb.Endpoint.broadcast!("room:lobby", "update_viewer_count", %{"viewer_count"=> get_viewer_count()})
    Process.send_after(self(), :work, 60000) # In 2 hours
  end
end

