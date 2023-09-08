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

    def member?(pile, {valeur, enseigne}) do
      carte = Carte.new(valeur, enseigne)
      {:ok, carte in pile.cartes}
    end

    def member?(pile, carte) do
      {:ok, carte in pile.cartes}
    end

    def reduce(pile, acc, func) do
      Enumerable.List.reduce(pile.cartes, acc, func)
    end

    def slice(%Pile{cartes: []}), do: {:ok, 0, fn _, _, _ -> [] end}
    def slice(_list), do: {:error, __MODULE__}
  end

  defimpl Inspect do
    def inspect(pile, options) do
      cartes = Enum.map(pile.cartes, fn carte -> Carte.nom(carte) end)
      Inspect.Algebra.concat(["#Pile", Inspect.Algebra.to_doc(cartes, options)])
    end
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