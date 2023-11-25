defmodule Console.Ecran.Parties do
  @moduledoc """
  Écran appelé pour afficher les parties existantes.
  """

  @behaviour Console.Ecran

  defstruct nom: :inconnu, choix: []

  @typedoc """
  Un écran `Console.Ecran.Parties`.
  """
  @type t() :: %{nom: String.t(), choix: %{String.t() => {integer(), pid()}}}

  @doc """
  Crée un écran.
  """
  @spec new(String.t()) :: t()
  def new(nom) do
    choix =
      Enum.map(Jeu.lister_parties(), fn {id, {processus, titre}} -> {id, processus, titre} end)
    %Console.Ecran.Parties{nom: nom, choix: choix}
  end

  @impl true
  @doc """
  Retourne le titre de l’ecran.
  """
  @spec titre(struct()) :: String.t()
  def titre(_ecran), do: "Parties de jeux de cartes actuelles"

  @impl true
  @doc """
  Retourne le texte de l’ecran.
  """
  @spec texte(struct()) :: String.t()
  def texte(ecran) do
    titres =
      for {{_, _, titre}, index} <- Enum.with_index(ecran.choix) do
        "#{index + 1} - #{titre}"
      end
    titres = Enum.join(titres, "\n")
    """
    Bienvenue, #{ecran.nom} !
    Pour jouer à une partie déjà créée, entrez simplement son numéro.
    Sinon, entrez C pour créer une nouvelle partie.
    Parties actuellement enregistrées :
    #{titres}
    """
  end

  @impl true
  @doc """
  Retourne le prompt de l’écran (le texte tout en bas, indiquant quelle information
  est à préciser ici).
  """
  @spec prompt(struct()) :: String.t()
  def prompt(_ecran), do: "Entrez le numéro de la partie à rejoindre ou C pour en créer une :"

  @impl true
  @doc """
    Gere les entrées claviers de l’utilisateur.
    Cette fonction peut retourner plusieurs informations :
    - `:silence` : indique à l’interface qu’il n’est pas nécessaire d’afficher l’écran
    de nouveau ;
    - `:prompt` : indique à l’interface qu’il est simplement nécessaire d’afficher de
    nouveau le prompt de l’écran, sans son texte ;
    - `:rafraîchir` : indique à l’interface qu’il faut afficher tout l’écran (titre,
    texte et prompt) ;
    - `{atome, texte}` : où `atome` est l’un des trois atomes ci-dessus et `texte` est
    le texte à afficher ;
    - `ecran` : où `ecran` est la nouvelle structure du module `ecran`.
  """
  @spec gerer_entree(struct(), String.t()) :: Console.Ecran.retour_clavier()
  def gerer_entree(ecran, "C") do
    regles = Jeu.Huit
    {id, processus} = Jeu.creer_partie(regles)
    {:ok, joueur} = Jeu.ajouter_joueur(id, processus, ecran.nom)
    :completer_ici_et_retourner_un_ecran
  end

  def gerer_entree(ecran, entree) do
    with {index, _} <- Integer.parse(entree),
        {:ok, choix} <- Enum.fetch(ecran.choix, index - 1) do
      {id, processus, titre} = choix
      case Jeu.ajouter_joueur(id, processus, ecran.nom) do
        {:ok, joueur} ->
          :completer_ici_et_retourner_un_ecran
        :invalide ->
          {:prompt, "Le joueur n’a pas pu être ajoute dans cette partie."}
      end
    else
      :error -> {:prompt, "Cette partie n’est pas valide."}
    end

  end
end