defmodule Carte do
  @moduledoc """
  Module gérant une `Carte` individuellement
  Ce module permet de créer une carte en spécifiant sa valeur
  (une chaîne de caractères) et son enseigne (une chaîne de caractères).
  Seules certaines valeurs et enseignes sont tolérées.
  """
  @valeur String.split("1 2 3 4 5 6 7 8 9 10 valet dame roi")
  @enseignes String.split("carreau coeur pique trèfle")

  @enforce_keys [:valeur, :enseigne]
  defstruct [:valeur, :enseigne]

  @typedoc "Une carte, avec une valeur et une enseigne"
  @type t() :: %Carte{valeur: String.t(), enseigne: String.t()}

  @typedoc "Erreur dans la création de la carte"
  @type carte_invalide() :: :valeur_invalide | :enseigne_invalide

  defimpl String.Chars do
    def to_string(carte) do
      Carte.nom(carte)
    end
  end

  defimpl Inspect do
    def inspect(carte, _opts) do
      Inspect.Algebra.concat(["#Carte<", Carte.nom(carte), ">"])
    end
  end

  @doc """
  Crée une nouvelle carte
  Si la valeur et l’enseigne sont correctes, retourne une structure
  `Carte`. Sinon, retourne un atome `:enseigne_invalide` ou
  `:valeur_invalide`, en fonction des cas.
  ## Exemples
  iex> Carte.new("3", "carreau")
  %Carte{enseigne: "carreau", valeur: "3"}
  iex> Carte.new("roi", "carreau")
  %Carte{enseigne: "carreau", valeur: "roi"}
  iex> Carte.new("112", "carreau")
  :valeur_invalide
  iex> Carte.new("9", "rouge")
  :enseigne_invalide
  iex> Carte.new("as", "pique")
  %Carte{enseigne: "pique", valeur: "1"}
  iex> Carte.new("as", "trefle")
  %Carte{enseigne: "trèfle", valeur: "1"}
  """
  @spec new(String.t(), String.t()) :: t() | carte_invalide()
  def new("as", enseigne), do: new("1", enseigne)
  def new(valeur, "trefle"), do: new(valeur, "trèfle")

  def new(valeur, enseigne) when valeur in @valeur and enseigne in @enseignes do
    %Carte{valeur: valeur, enseigne: enseigne}
  end

  def new(valeur, _enseigne) when valeur in @valeur do
    :enseigne_invalide
  end

  def new(_valeur, _enseigne)do
    :valeur_invalide
  end

  @doc """
  Retourne le nom de la carte en Français

  ## Exemples
    iex> Carte.nom(Carte.new("3", "trèfle"))
    "3 de trèfle"
    iex> Carte.nom(Carte.new("1", "carreau"))
    "as de carreau"
  """
  def nom(carte) do
    if carte.valeur == "1" do
      "as de #{carte.enseigne}"
    else
      "#{carte.valeur} de #{carte.enseigne}"
    end
  end

  @doc """
  Retourne une liste de 52 cartes
  """
  @spec toutes() :: [t()]
  def toutes() do
    for enseigne <- @enseignes, valeur <- @valeur do
      new(valeur, enseigne)
    end
  end


end

