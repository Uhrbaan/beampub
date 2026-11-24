defmodule BeamPub.Social.Actor.Outbox do
  alias BeamPub.ActivityPub.Activities.{Create, Follow}
  alias BeamPub.ActivityPub.Objects.Note
  alias BeamPub.Social.Actor

  def handle({:follow, target}, state) do
    me = state.username

    activity = %Follow{
      id: "follow-#{System.unique_integer([:positive])}",
      actor: me,
      object: target
    }

    GenServer.cast(Actor.via(target), {:inbox, activity})

    # FIXME: right now followee does not wait for an accept response before adding the follower
    %{state | outbox: [activity | state.outbox], following: MapSet.put(state.following, target)}
  end

  def handle({:publish, content}, state) do
    note = %Note{
      id: "note-#{System.unique_integer([:positive])}",
      attributed_to: state.username,
      content: content,
      published: DateTime.utc_now()
    }

    activity = %Create{
      id: "activity-#{System.unique_integer([:positive])}",
      actor: state.username,
      object: note
    }

    Enum.each(state.followers, fn follower ->
      GenServer.cast(Actor.via(follower), {:inbox, activity})
    end)

    %{state | outbox: [activity | state.outbox]}
  end
end
