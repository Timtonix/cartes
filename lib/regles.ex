defmodule Regles do
  @moduledoc """
  Modèle de comportement des règles du jeu.
  Tous les jeux doivent implémenter ce comportement.
  """
  @typedoc "Un coup utilisable en jeu"
  @type coup :: atom() | tuple()
  @doc """
  Retourne le titre du jeu sous la forme d’une chaîne de caractères.
  """
  @callback titre() :: String.t()

  @doc """
  Crée une nouvelle structure.
  Cette fonction retourne la structure propre aux règles de jeu
  (probablement définie dans le module spécifique).
  """
  @callback new() :: struct()
  @doc """
  Retourne `true` si l’on peut ajouter un nouveau joueur au jeu, `false` sinon.
  """
  @callback ajouter_joueur?(struct()) :: boolean()
  @doc """
  Ajoute un joueur.
  On doit préciser en paramètres le jeu lui-même et le nom du joueur
  à ajouter. La fonction `ajouter_joueur?` doit avoir été appelée auparavant.
  Un tuple est retourné contenant le jeu modifié et l’identifiant
  du joueur ajouté (un entier).
  """
  @callback ajouter_joueur(struct(), String.t()) :: {struct(), integer()}
  @doc """
  Est-ce que ce coup est permis ?
  Retourne soit `true`, soit `false`.
  On doit préciser en paramètres le jeu lui-même, le joueur sous forme
  d’entier et le coup à jouer : ce dernier peut être un atome (comme
  `:piocher`) ou un tuple (comme `{:jouer, %Carte{}}`).
  """
  @callback jouer?(struct(), integer(), coup()) :: boolean()
  @doc """
  Fait jouer un joueur.
  On doit spécifier en paramètres le jeu lui-même, le joueur sous la forme
  d’un entier et le coup à réaliser (un atome ou un tuple
  dont le premier élément est un atome).
  La fonction `jouer?` doit avoir été appelée auparavant.
  Le jeu modifié est retourné.
  """
  @callback jouer(struct(), integer(), coup()) :: struct()
end