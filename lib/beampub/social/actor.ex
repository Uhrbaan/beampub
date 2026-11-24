defmodule BeamPub.Social.Actor do
  @moduledoc """
  Processus GenServer représentant un utilisateur local et gérant son état interne.

  Spécification ActivityPub (Section 4 - Actors) :
  https://www.w3.org/TR/activitypub/#actor-objects
  """
  use GenServer

  alias BeamPub.Social.Actor.{Inbox, Outbox}
  alias BeamPub.Social.Actor

  defstruct [
    :username,
    inbox: [],
    outbox: [],
    followers: MapSet.new(),
    following: MapSet.new()
  ]

  ### API ###

  # a function that checks up the registry entry based ont he username
  def via(username) do
    {:via, Registry, {BeamPub.ActorRegistry, username}}
  end

  def start_link(username) when is_binary(username) do
    GenServer.start_link(__MODULE__, username, name: via(username))
  end

  # Bob (follower) initie un suivi vers Alice (followee) via son propre Outbox
  def follow(follower, followee) do
    GenServer.cast(Actor.via(follower), {:outbox, {:follow, followee}})
  end

  # actor_pid publie un contenu via son Outbox
  def publish(actor, content) do
    GenServer.cast(Actor.via(actor), {:outbox, {:publish, content}})
  end

  def get_inbox(actor) do
    GenServer.call(Actor.via(actor), :get_inbox)
  end

  ### Server Callbacks ###

  @impl true
  def init(username) do
    {:ok, %__MODULE__{username: username}}
  end

  @impl true
  def handle_cast({:outbox, action}, state) do
    IO.puts("📤 [#{state.username} -> OUTBOX] Action : #{inspect(action)}")
    new_state = Outbox.handle(action, state)
    {:noreply, new_state}
  end

  @impl true
  def handle_cast({:inbox, activity}, state) do
    IO.puts("📥 [INBOX -> #{state.username}] Activité reçue : #{inspect(activity.__struct__)}")
    new_state = Inbox.handle(activity, state)

    Phoenix.PubSub.broadcast(
      BeamPub.PubSub,
      "timeline:#{state.username}",
      {:inbox_updated, new_state.inbox}
    )

    {:noreply, new_state}
  end

  @impl true
  def handle_call(:get_inbox, _from, state) do
    {:reply, state.inbox, state}
  end
end
