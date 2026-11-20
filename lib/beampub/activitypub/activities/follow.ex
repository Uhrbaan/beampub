defmodule BeamPub.ActivityPub.Activities.Follow do
  @moduledoc """
  Activité demandant à s'abonner aux publications d'un autre acteur.

  Spécification ActivityPub (Section 6.5 - Follow Activity) :
  https://www.w3.org/TR/activitypub/#follow-activity-outbox
  Spécification ActivityStreams 2.0 :
  https://www.w3.org/TR/activitystreams-vocabulary/#dfn-follow
  """

  @enforce_keys [:id, :actor, :object]
  defstruct [
    # URI unique de la demande d'abonnement
    :id,
    # URI de l'acteur qui souhaite suivre
    :actor,
    # URI de l'acteur cible qui est suivi
    :object
  ]
end
