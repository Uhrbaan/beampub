defmodule BeamPub.Social.Actor.Outbox do
  def handle({:follow, pid}, state) do
    # Create the follow activity
    activity = %BeamPub.ActivityPub.Activities.Follow{
      id: "follow-#{System.unique_integer([:positive])}",
      actor: self(),
      object: pid
    }

    # Send the activity to the user's inbox
    GenServer.cast(pid, {:inbox, activity})

    # Update own state
    %{state | outbox: [activity | state.outbox], following: MapSet.put(state.following, pid)}
  end

  def handle({:publish, content}, state) do
    # Build the ActivityPub structs
    note = %BeamPub.ActivityPub.Objects.Note{
      id: "note-#{System.unique_integer([:positive])}",
      attributed_to: state.username,
      content: content,
      published: DateTime.utc_now()
    }

    # Note: in activitypub, the create activity contains the :to, :cc and other fields, which we ignore in our simplified system.
    # We also ignore the :publish field since we already store it for the note.
    activity = %BeamPub.ActivityPub.Activities.Create{
      id: "activity-#{System.unique_integer([:positive])}",
      actor: state.username,
      object: note
    }

    # Send the activity to every follower's mailbox
    Enum.each(state.followers, fn follower_pid ->
      GenServer.cast(follower_pid, {:inbox, activity})
    end)

    # Update own state
    %{state | outbox: [activity | state.outbox]}
  end
end
