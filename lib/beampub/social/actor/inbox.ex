defmodule BeamPub.Social.Actor.Inbox do
  alias BeamPub.ActivityPub.Activities.{Accept, Create, Follow}

  # Public entry point called by BeamPub.Social.Actor
  def handle(%Follow{actor: follower_pid} = follow, state) do
    # ActivityPub specifies that a Follow MUST return an Accept activity
    #  Return it automatically without user confirmation
    accept = %Accept{
      id: new_id("accept"),
      actor: self(),
      object: follow
    }

    GenServer.cast(follower_pid, {:inbox, accept})

    state
    |> record_inbox(follow)
    |> Map.update!(:followers, &MapSet.put(&1, follower_pid))
  end

  def handle(%Create{} = create, state), do: record_inbox(state, create)
  def handle(%Accept{} = accept, state), do: record_inbox(state, accept)

  # Private helpers
  defp record_inbox(state, activity), do: %{state | inbox: [activity | state.inbox]}
  defp new_id(prefix), do: "#{prefix}-#{System.unique_integer([:positive])}"
end
