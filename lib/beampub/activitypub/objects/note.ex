defmodule BeamPub.ActivityPub.Objects.Note do
  @moduledoc """
  Représente un message court (statut/pouet).

  Spécification ActivityStreams 2.0 (Object Types - Note) :
  https://www.w3.org/TR/activitystreams-vocabulary/#dfn-note
  """

  @enforce_keys [:id, :attributed_to, :content]
  defstruct [
    # URI unique de la note (ex: "https://mon-domaine/notes/123")
    :id,
    # URI ou handle de l'auteur
    :attributed_to,
    # Contenu texte ou HTML du message
    :content,
    # DateTime (ISO 8601)
    :published,
    # Compteur interne pour l'affichage UI
    likes: 0
  ]
end
