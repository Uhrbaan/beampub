defmodule BeamPub.ActivityPub.Activities.Accept do
  @moduledoc """
  ActivityStreams 2.0 Accept Activity:
  https://www.w3.org/TR/activitystreams-vocabulary/#dfn-accept
  """
  @enforce_keys [:id, :actor, :object]
  defstruct [
    :id,
    :actor,
    :object,
  ]
end
