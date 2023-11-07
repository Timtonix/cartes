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
 @spec condensee(struct(), integer()) :: map()
 def condensee(jeu, joueur) do
   %{mains: jeu.mains[joueur], visible: jeu.visible}
 end
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

    %Jeu.Huit{pioche: pioche, visible: Enum.at(visibles, 0), defausse: visibles}
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
    IO.inspect(numero_joueur, label: "JEU.HUIT")
    {jeu, numero_joueur}
  end

  @impl true
  @doc """
  Retourne la liste des coups possibles pour un joueur
  """
  @spec coups(struct(), integer()) :: [{atom() | tuple(), String.t(), boolean()}]
  def coups(jeu, joueur) do
    main = jeu.mains[joueur]
    identifiants = for carte <- main, do: {{:jouer, carte}, to_string(carte)}
    identifiants = [{:piocher, "piocher"} | identifiants]

    for {coup, nom} <- identifiants do
      {coup, nom, jouer?(jeu, joueur, coup)}
    end
  end


  @impl true
  @doc """
  Retourne `true` si le joueur peut jouer un coup, `false` sinon.
  On doit préciser le coup, le joueur et le jeu.

  Le coup peut être un atom comme `:piocher` ou un tple `{:jouer, carte}`
  """
  @spec jouer?(struct(), integer(), Regles.coup()) :: boolean()
  def jouer?(jeu, joueur, _) when joueur != jeu.actuel do
    false
  end

  def jouer?(jeu, joueur, :piocher) do

  end

  def jouer?(jeu, joueur, {:jouer, valeur, enseigne}) do
    # En utilisant plutot la récursion
    carte = Carte.new(valeur, enseigne)
    case carte do
      %Carte{} -> jouer?(jeu, joueur, {:jouer, carte})
      _ -> false
    end
  end

  def jouer?(jeu, joueur, {:jouer, %Carte{valeur: "8"} = carte}) do
    carte in jeu.mains[joueur]
  end

  def jouer?(jeu, joueur, {:jouer, %Carte{} = carte}) do
    carte in jeu.mains[joueur] and (carte.valeur == jeu.visible.valeur or carte.enseigne == jeu.visible.enseigne)
  end

  def jouer?(_jeu, _joueur, _coup) do
    false
  end

  @impl true
  @doc """
  Fait jouer un joueur.

  Params:
    jeu: cela permet de faire les modifiactions
    joueur: sous la forme d'un entier
    coup: un atom, ou un tuple avec une carte. L'action à faire
  On doit d'abord appeler la fonction `jouer?` sinon ça marche pas.
  Returns:
    Le jeu modifié
  """
  @spec jouer(struct(), integer(), Regles.coup()) :: struct()
  def jouer(jeu, _joueur, :piocher) do
    jeu
    |> piocher(jeu.actuel)
    |> valider_tour()
  end

  def jouer(jeu, joueur, {:jouer, valeur, enseigne}) do
    carte = Carte.new(valeur, enseigne)
    case carte do
      %Carte{} -> jouer(jeu, joueur, {:jouer, carte})
      _ -> :invalide
    end
  end
  def jouer(jeu, _joueur, {:jouer, %Carte{valeur: "1"} = carte}) do
    jeu
    |> jouer_carte(carte)
    |> changer_sens()
    |> valider_tour()
  end
  def jouer(jeu, joueur, {:jouer, %Carte{valeur: "2"} = carte}) do
    jeu
    |> jouer_carte(carte)
    |> piocher(joueur_suivant(jeu, joueur), 2)
    |> valider_tour(2)
  end
  def jouer(jeu, _joueur, {:jouer, %Carte{valeur: "valet"} = carte}) do
    jeu
    |> jouer_carte(carte)
    |> valider_tour(2)
  end

  def jouer(jeu, _joueur, {:jouer, %Carte{} = carte}) do
    jeu
    |> jouer_carte(carte)
    |> valider_tour()
  end

  @spec jouer_carte(t(), Carte.t()) :: t()
  defp jouer_carte(jeu, carte) do
    main = jeu.mains[jeu.actuel]
    {main, defausse} = Pile.transferer(main, jeu.defausse, carte)
    mains = Map.put(jeu.mains, jeu.actuel, main)
    %{jeu | defausse: defausse, mains: mains, visible: carte}
  end

  @spec valider_tour(t(), integer()) :: t()
  defp valider_tour(jeu, nombre \\ 1) do
    actuel = Enum.reduce(1..nombre, jeu.actuel, fn _, pos -> joueur_suivant(jeu, pos) end)
    %{jeu | actuel: actuel}
  end

  @spec joueur_suivant(t(), integer()) :: integer()
  defp joueur_suivant(jeu, actuel) do
    maximum = Kernel.map_size(jeu.mains)-1

    case jeu.sens do
      :ordinaire -> (actuel >= maximum && 0) || actuel + 1
      :inverse -> (actuel > 0 && actuel-1) || maximum
    end
  end

  @spec changer_sens(t()) :: t()
  defp changer_sens(jeu) do
    sens =
      case jeu.sens do
        :ordinaire -> :inverse
        :inverse -> :ordinaire
      end
    %{jeu | sens: sens}
  end

  @spec piocher(t(), integer(), integer()) :: t()
  defp piocher(jeu, joueur, nombre \\ 1) do
    {pioche, defausse} =
      if Pile.taille(jeu.pioche) < nombre do
        pioche = Pile.fusionner(jeu.defausse, jeu.pioche) |> Pile.melanger()
        {pioche, Pile.new()}
      else
        {jeu.pioche, jeu.defausse}
      end

    {piochees, pioche} = Pile.retirer(pioche, nombre)
    main = Pile.fusionner(jeu.mains[joueur], piochees)
    mains = Map.put(jeu.mains, joueur, main)
    %{jeu | defausse: defausse, mains: mains, pioche: pioche}
  end
end

