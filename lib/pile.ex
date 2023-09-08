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

  defimpl Enumerable do
    def count(pile), do: {:ok , Pile.taille(pile)}
  end
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

  @doc """
  Retourne la taille de la pile de carte

  ## Exemples
    iex>Pile.new |> Pile.taille
    0
    iex>Pile.new |> Pile.ajouter("7", "trèfle") |> Pile.taille
    1
  """
  @spec taille(t()) :: integer()
  def taille(pile), do: length(pile.cartes)
end