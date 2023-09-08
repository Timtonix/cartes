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
  Créer une pile avec un certain nombre de cartes à l'intérieur

  Deux valeurs sont pssibles : 0 ou 52 (0 vide, 52 pleine)

  ## Exemples
    iex>Pile.new(0)
    %Pile{cartes: []}

    iex>pile = Pile.new(52)
    iex>{"1", "pique"} in pile
    true
    iex>{"7", "carreau"} in pile
    true
    iex>Pile.taille(pile)
    52
  """
  @spec new(0 | 52) :: t()
  def new(0), do: %Pile{}

  def new(52) do
    %Pile{cartes: Carte.toutes()}
  end
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

  @doc """
  Mélange les cartes de la pile semi-aléatoirement

  On utilise `Enum.shuffle` avec un *seed* qui nous permet de prédire le résultat

  ## Exemples
    iex> :rand.seed(:exsss, {100, 101, 102})
    iex> pile = Pile.new(52) |> Pile.melanger()
    iex> List.first(pile.cartes)
    #Carte<10 de coeur>
    iex> Pile.taille(pile)
    52
  """
  @spec melanger(t()) :: t()
  def melanger(pile) do
    %{pile | cartes: Enum.shuffle(pile)}
  end

  @doc """
  Retire un certain nombre de cartes de la pile

  Le nombre par défaut est 1, si on retire plus de carte qu'il n'y en a, on retire au maximum.
  On retire les carte par le dessus de la pile.

  ## Exemples
    iex> {retirées, restantes} =
    iex> Pile.new()
    iex> |> Pile.ajouter("as", "pique")
    iex> |> Pile.ajouter("roi", "trèfle")
    iex> |> Pile.ajouter("roi", "carreau")
    iex> |> Pile.retirer(2)
    iex> {"roi", "trèfle"} in retirées
    true
    iex> {"roi", "carreau"} in retirées
    true
    iex> {"as", "pique"} in retirées
    false
    iex> Pile.taille(retirées)
    2
    iex> Pile.taille(restantes)
    1
  """
  @spec retirer(t(), number()) :: {t(), t()}
  def retirer(pile, nombre \\ 1) when is_number(nombre) and nombre > 0 do
    retirees = Enum.take(pile, nombre)
    restantes = Enum.drop(pile, nombre)
    {%Pile{cartes: retirees}, %{pile | cartes: restantes}}
  end

  @doc """
  Transfère une carte d'une pioche vers le sommet d'une autre (main vers pioche par exemple)
  Prends en premier paramètre la pile d'origine, ensuite la pile de destination et enfin la carte en question

  ## Exemples
    iex> origine = Pile.new() |> Pile.ajouter("as", "trèfle") |>  Pile.ajouter("as", "coeur")
    iex> destination = Pile.new() |> Pile.ajouter("as", "carreau")
    iex> {origine, destination} = Pile.transferer(origine, destination, {"as", "coeur"})
    iex> {"as", "coeur"} in destination
    true
    iex> {"as", "coeur"} in origine
    false
  """
  @spec transferer(t(), t(), {String.t(), String.t()}) :: {t(), t()}
  def transferer()
end