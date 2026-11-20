defmodule BeamPub.ActivityPub.Activities.Create do
  @moduledoc """
  Activité indiquant qu'un acteur a créé un nouvel objet (généralement une Note).

  Spécification ActivityPub (Section 6.2 - Create Activity) :
  https://www.w3.org/TR/activitypub/#create-activity-outbox
  Spécification ActivityStreams 2.0 :
  https://www.w3.org/TR/activitystreams-vocabulary/#dfn-create
  """

  @enforce_keys [:id, :actor, :object]
  defstruct [
    # URI unique de l'activité
    :id,
    # URI de l'auteur de l'action
    :actor,
    # L'objet créé (ex: %BeamPub.ActivityPub.Objects.Note{})
    :object
  ]
end
