defmodule BeamPub.Social.Actor do
  @moduledoc """
  Processus GenServer représentant un utilisateur local et gérant son état interne.

  Spécification ActivityPub (Section 4 - Actors) :
  https://www.w3.org/TR/activitypub/#actor-objects
  """
  use GenServer

  alias BeamPub.Social.Actor.{Inbox, Outbox}

  defstruct [
    :username,
    inbox: [],
    outbox: [],
    followers: MapSet.new(),
    following: MapSet.new()
  ]

  ### API ###

  def start_link(username) do
    GenServer.start_link(__MODULE__, username)
  end

  # Bob (follower_pid) initie un suivi vers Alice (target_pid) via son propre Outbox
  def follow(follower_pid, target_pid) do
    GenServer.cast(follower_pid, {:outbox, {:follow, target_pid}})
  end

  # actor_pid publie un contenu via son Outbox
  def publish(actor_pid, content) do
    GenServer.cast(actor_pid, {:outbox, {:publish, content}})
  end

  def get_inbox(actor_pid) do
    GenServer.call(actor_pid, :get_inbox)
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

    {:noreply, new_state}
  end

  @impl true
  def handle_call(:get_inbox, _from, state) do
    {:reply, state.inbox, state}
  end
end
