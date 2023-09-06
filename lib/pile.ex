defmodule Pile do
  @moduledoc """
  Module définissant une pile de cartes
  On peut ajouter des cartes sur cette pile. Utiliser la fonction
  `ajouter` pour ce faire : la carte ajoutée sera placée au sommet
  de la pile.
  """
  defstruct cartes: []
  @typedoc "Une pile de cartes dans un ordre précis."
  @type t() :: %Pile{cartes: [Carte.t()]}
  @doc """
  Crée une pile vide.
  ## Exemples
  iex> Pile.new()
  %Pile{cartes: []}
  """
  @spec new() :: t()
  def new(), do: %Pile{}

  @doc """
  Prends la pile de carte existante et lui ajoute la carte renseignée
  ## Exemples
  iex>Pile.ajouter(%Pile{}, "roi", "coeur")
  %Pile{cartes: [%Carte{valeur: "roi", enseigne: "coeur"}]}
  """
  @spec ajouter(t(), String.t(), String.t()) :: t() | Carte.carte_invalide()
  def ajouter(pile, valeur, enseigne) do
    carte = Carte.new(valeur, enseigne)

    case carte do
      %Carte{} ->
        %Pile{cartes: [carte | pile.cartes]}
      erreur ->
        erreur
    end
  end
end