defmodule Jeu.Huit do
  @moduledoc """
  Implémentation du jeu de 8 américain.
  """
  @behaviour Regles
  defstruct actuel: 0, defausse: Pile.new(), mains: %{}, noms: %{},
      pioche: Pile.new(), sens: :ordinaire, visible: nil

  @typedoc "Un jeu de 8 américain"
  @type t() :: %{
    actuel: integer(),
    defausse: Pile.t(),
    mains: %{integer() => Pile.t()},
    noms: %{integer() => String.t()},
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

  @impl true
  @doc """
  Return `true` si l'on peut ajouter un nouveau joueur au jeu, `false` sinon.

  On ne peut pas ajouter plus de 5 joueurs (7*5 = 35)

  ### Exemples
      iex> jeu = Jeu.Huit.new()
      iex> Jeu.Huit.ajouter_joueur?(jeu)
      true
      iex> noms = for i <- 1..5 ,into: %{}, do: {i, ""}
      iex> jeu = %{jeu | noms: noms}
      iex> Jeu.Huit.ajouter_joueur?(jeu)
      false
  """
  @spec ajouter_joueur?(struct()) ::boolean()
  def ajouter_joueur?(jeu) do
    map_size(jeu.noms) < 5
  end

  @impl true
  @doc """
  Un fonction qui ajoute un joueur et lui donne 7 cartes de la pile
  """
  @spec ajouter_joueur(struct(), String.t()) :: {struct(), integer()}
  def ajouter_joueur(jeu, joueur) do
    {cartes_joueur, pioche} = Pile.retirer(jeu.pioche, 7)
    numero_joueur = map_size(jeu.noms)
    mains = Map.put(jeu.mains, numero_joueur, cartes_joueur)
    noms = Map.put(jeu.noms, numero_joueur, joueur)
    jeu = %{jeu | mains: mains, noms: noms, pioche: pioche}
    {jeu, numero_joueur}
  end

  @impl true
  @doc """
  Retourne `true` si le joueur peut jouer un coup, `false` sinon.
  On doit préciser le coup, le joueur et le jeu.

  Le coup peut être un atom comme `:piocher` ou un tple `{:jouer, carte}`
  """
  @spec jouer?(struct(), integer(), atom() | tuple()) :: boolean()
  def jouer?(jeu, joueur, coup) do
    true
  end

end
