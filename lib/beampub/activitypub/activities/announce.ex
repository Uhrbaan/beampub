defmodule BeamPub.ActivityPub.Activities.Announce do
  @moduledoc """
  Activité permettant de partager l'objet d'un autre acteur à ses propres abonnés (Boost / Retweet).

  Spécification ActivityPub (Section 6.7 - Announce Activity) :
  https://www.w3.org/TR/activitypub/#announce-activity-outbox
  Spécification ActivityStreams 2.0 :
  https://www.w3.org/TR/activitystreams-vocabulary/#dfn-announce
  """

  @enforce_keys [:id, :actor, :object]
  defstruct [
    # URI unique du partage
    :id,
    # URI de l'acteur qui partage
    :actor,
    # URI de l'objet partagé
    :object
  ]
end
