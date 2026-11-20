defmodule BeamPubWeb.TimelineLive do
  use BeamPubWeb, :live_view

  alias BeamPub.Social.Actor
  alias BeamPub.ActivityPub.Activities.Create

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket) do
      Phoenix.PubSub.subscribe(BeamPub.PubSub, "timeline:alice")
    end

    # Checks if the :alice process is alive via Process.whereis/1
    inbox = if Process.whereis(:alice), do: Actor.get_inbox(:alice), else: []

    {:ok, assign(socket, inbox: inbox)}
  end

  @impl true
  def handle_info({:inbox_updated, new_inbox}, socket) do
    {:noreply, assign(socket, inbox: new_inbox)}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="max-w-xl mx-auto p-8 space-y-4">
      <h1 class="text-2xl font-bold">Alice's Inbox</h1>

      <%= if @inbox == [] do %>
        <p class="text-gray-500">Nothing here yet...</p>
      <% end %>

      <%= for %Create{actor: author, object: note} <- @inbox do %>
        <div class="border p-4 rounded shadow-sm bg-white">
          <p class="text-sm font-semibold text-blue-600">@<%= author %></p>
          <p class="mt-1"><%= note.content %></p>
        </div>
      <% end %>
    </div>
    """
  end
end
