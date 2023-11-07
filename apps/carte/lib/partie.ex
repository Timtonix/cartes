defmodule Partie do
  @moduledoc """
  Serveur générique contenant une partie de jeu de cartes en cours.
  """
  use GenServer

  @enforce_keys [:id, :regles, :jeu]

  defstruct [:id, :regles, :jeu]

  @type t() :: %{
    id: integer(),
    regles: module(),
    jeu: struct()
  }

  @doc """
  Crée une nouvelle partie.
  """
  @spec start_link({integer(), module()}, GenServer.options()) :: GenServer.on_start()
  def start_link({id, regles}, options \\ []) do
    options = Keyword.put(options, :name, nom_processus(id))
    GenServer.start_link(__MODULE__, {id, regles}, options)
  end

  @doc """
  Tente d'ajouter un joueur

  Si le jeu refuse -> :invalide
  Sinon le joueur est ajouté à la partie en cours et le jeu est retourné
  """
  @spec ajouter_joueur(integer() | pid(), String.t()) :: {integer(), struct()} | :invalide
  def ajouter_joueur(id, nom) when is_integer(id) do
    ajouter_joueur(nom_processus(id), nom)
  end

  def ajouter_joueur(pid, nom) do
    GenServer.call(pid, {:ajouter_joueur, nom})
  end

  @doc """
  Fait jouer le joueur donné
   Le coup est sous la forme d'un atom ou tuple
  Si le coup est accepté -> Retourne le jeu
  Sinon -> :invalide
  """
  @spec jouer(integer() | pid(), integer(), atom() | any()) :: struct() | :invalide
  def jouer(id, joueur, coup) when is_integer(id) do
    jouer(nom_processus(id), joueur, coup)
  end

  def jouer(pid, joueur, coup) do
    GenServer.call(pid, {:jouer, joueur, coup})
  end

  @spec condensee(integer() | pid(), integer()) ::map()
  def condensee(id, joueur) when is_integer(id) do
    condensee(nom_processus(id), joueur)
  end

  def condensee(pid, joueur) do
    GenServer.call(pid, {:condensee, joueur})
  end



  @spec coups(integer() | pid(), integer()) :: [{atom() | tuple(), String.t(), boolean()}]
  def coups(id, joueur) when is_integer(id) do
    coups(nom_processus(id), joueur)
  end

  def coups(pid, joueur) do
    GenServer.call(pid, {:coups, joueur})
  end

  @spec condenser_pour(t(), integer()) ::map()
  def condenser_pour(partie, joueur) do
    partie.regles.condensee(partie.jeu, joueur)
  end

  @spec nom_processus(integer()) :: tuple()
  defp nom_processus(id) do
    {:via, Registry, {Partie.Registre, id}}
  end

  @impl true
  @spec init(module()) :: {:ok, %Partie{}}
  def init({id, regles}) do
    IO.puts("Création de la partie")
    {:ok, %Partie{id: id, regles: regles, jeu: regles.new()}}
  end

  @impl true
  def handle_call({:coups, joueur}, _from, partie) do
    coups = partie.regles.coups(partie.jeu, joueur)
    {:reply, coups, partie}
  end

  @impl true
  def handle_call({:condensee, joueur}, _from, partie) do
    {:reply, condenser_pour(partie, joueur), partie}
  end

  @impl true
  def handle_call({:ajouter_joueur, nom}, _from, partie) do
    if partie.regles.ajouter_joueur?(partie.jeu) do
      {jeu, joueur} = partie.regles.ajouter_joueur(partie.jeu, nom)
      partie = %{partie | jeu: jeu}
      {:reply, {:ok, joueur}, partie}
    else
      {:reply, :invalide, partie}
    end
  end

  @impl true
  def handle_call({:jouer, joueur, coup}, _from, partie) do
    if partie.regles.jouer?(partie.jeu, joueur, coup) do
      jeu = partie.regles.jouer(partie.jeu, joueur, coup)
      partie = %{partie | jeu: jeu}
      {:reply, condenser_pour(partie, joueur), partie}
    else
      {:reply, :invalide, partie}
    end
  end


end
