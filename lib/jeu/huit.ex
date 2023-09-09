defmodule Jeu.Huit do
  @moduledoc """
  Implémentation du jeu de 8 américain.
  """
  @behaviour Regles
  defstruct actuel: 0, defausse: Pile.new(), mains: %{}, noms: %{},
      pioche: Pile.new(), sens: ordinaire, visible: nil

  @typedoc "Un jeu de 8 américain"
  @type t() :: %{
    actuel: integer(),
    defausse: Pile.t(),
    mains: %{integer() => Pile.t()},noms: %{integer(), String.t()},
    pioche: String.t(),
    sens: :ordinaire | :inverse,
    visible: Carte.t()
               }
  @impl true
  @doc """
     Retourne le titre du jeu sous la forme d’une chaîne de caractères.
     """
   @spec titre() :: String.t()
   def titre(), do: "Le 8 américain"

 @impl true
  @doc """
  Crée une nouvelle structure.
  Cette fonction retourne la structure propre aux règles de jeu
  (probablement définie dans le module spécifique).
  """
  @spec new() :: t()
end