defmodule Console.Ecran.NomJoueur do
  @moduledoc """
  Écran appelé simplement pour demander le nom du joueur actuel.
  """

  @behaviour Console.Ecran

  defstruct []

  @typedoc """
  Un écran vide.
  """
  @type t() :: %{}

  @doc """
  Crée un nouvel écran.
  """
  @spec new() :: t()
  def new(), do: %Console.Ecran.NomJoueur{}


  @impl true
  @doc """
  Retourne le titre de l’écran.
  """
  @spec titre(struct()) :: String.t()
  def titre(_ecran), do: "Nom de votre joueur"


  @impl true
  @doc """
  Retourne le texte de l’écran.
  """
  @spec texte(struct()) :: String.t()
  def texte(_ecran) do
    """
    Vous devez préciser le nom de votre joueur. Cette information ne servira qu’à
    vous identifier auprès des joueurs connectés à la plate-forme.
    """
  end

  @impl true
  @doc """
  Retourne le prompt de l’écran (le texte tout en bas, indiquant quelle information
  est à préciser ici).
  """
  @spec prompt(struct()) :: String.t()
  def prompt(_ecran), do: "Entrez le nom de votre joueur :"

  @impl true
  @doc """
    Gère les entrées claviers de l’utilisateur.
    Cette fonction peut retourner plusieurs informations :
    - `:silence` : indique à l’interface qu’il n’est pas nécessaire d’afficher l’écran
    de novueau ;
    - `:prompt` : indique à l’interface qu’il est simplement nécessaire d’afficher de
    nouveau le prompt de l’écran, sans son texte ;
    - `:rafraîchir` : indique à l’interface qu’il faut afficher tout l’écran (titre,
    texte et prompt) ;
    - `{atome, texte}` : où `atome` est l’un des trois atomes ci-dessus et `texte` est
    le texte à afficher ;
    - `écran` : où `écran` est la nouvelle structure du module `écran`.
    """
  @spec gerer_entree(struct(), String.t()) :: Console.Ecran.retour_clavier()
  def gerer_entree(_ecran, entree) do
    if String.length(entree) < 3 do
      {:prompt, "Le nom du joueur doit contenir au moins 3 caractères."}
    else
      Console.Ecran.Parties.new(entree)
    end
  end
end