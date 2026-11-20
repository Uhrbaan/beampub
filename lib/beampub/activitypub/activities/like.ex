defmodule BeamPub.ActivityPub.Activities.Like do
  @moduledoc """
  Activité indiquant qu'un acteur apprécie un objet (Favori).

  Spécification ActivityPub (Section 6.6 - Like Activity) :
  https://www.w3.org/TR/activitypub/#like-activity-outbox
  Spécification ActivityStreams 2.0 :
  https://www.w3.org/TR/activitystreams-vocabulary/#dfn-like
  """

  @enforce_keys [:id, :actor, :object]
  defstruct [
    # URI unique du Like
    :id,
    # URI de l'acteur qui aime
    :actor,
    # URI de l'objet aimé (ex: l'ID d'une Note)
    :object
  ]
end
