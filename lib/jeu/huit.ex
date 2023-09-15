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
    pioche: Pile.t(),
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

  ## Exemples
    iex> huit = Jeu.Huit.new()
    iex> Pile.taille(huit.pioche)
    51
  """
  @spec new() :: t()
  def new() do
    pioche = Pile.new(52) |> Pile.melanger()
    {visibles, pioche} = Pile.retirer(pioche, 1)

    %Jeu.Huit{pioche: pioche, visible: Enum.at(visibles, 0)}
  end
end