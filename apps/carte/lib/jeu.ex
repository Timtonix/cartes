defmodule Jeu do
  @moduledoc """
  Point d’entrée du jeu de cartes.
  Ce module doit être appelé :
  - Pour créer une partie de jeu de cartes ;
  - Pour connaître la partie (PID) correspondant à un identifiant ;
  - Pour connaître la liste des parties en cours sur cette instance ou le cluster ;
  - Pour ajouter un joueur et jouer à une partie.
  Il est donc complètement découplé du système d’interface et peut être
  utilisé par une autre application, quelle que soit l’interface implémentée.
  """
  use GenServer
  @doc """
  Lance le point d’entrée. Un seul point d’entrée doit être créé par instance.
  """
  @spec start_link(GenServer.options()) :: GenServer.on_start()
  def start_link(options \\ []) do
    options = Keyword.put(options, :name, :entree)
    GenServer.start_link(__MODULE__, nil, options)
  end

  @doc """
  Crée une nouvelle partie de jeu de cartes.

  On précise en paramètre le mode de jeu (`Jeu.Huit` par exemple)
  L'identifiant de la partie est crée à la volée, tout en sachant que cette partie sera hébergée sur l'instance la moins chargée.
    L'ID et le PID de la partie seront retournés en tuple
  """
  @spec creer_partie(module()) :: {integer(), pid()}
  def creer_partie(regles) do
    petite_charge = Enum.min_by(points_entree(), fn processus -> nombre_parties(processus) end)
    GenServer.call(petite_charge, {:creer_partie, regles})
  end

  @doc """
  Retourne le nombre de parties en cours sur l'instance
  """
  @spec nombre_parties(pid()) :: integer()
  def nombre_parties(processus) do
    GenServer.call(processus, :nombre_parties)
  end

  @doc """
  Cherche une partie à partir de son identifiant
  Si la partie est trouvée, on retourne son PID, sinon `nil`
  La recherche s'effectue sur chacune des instances exécutant l'application carte
  """
  @spec trouver_partie(integer()) :: pid() | nil
  def trouver_partie(identifiant) do
    Enum.find_value(points_entree(), fn entree -> GenServer.call(entree, {:trouver_partie, identifiant}) end)
  end

  @doc """
  Retourne `true` si on trouve une instance de Jeu
    `false` sinon.
  """
  @spec peut_communiquer?() :: true | false
  def peut_communiquer?() do
    length(points_entree()) != 0
  end


  @doc """
  Retourne une map (identifiant => {PID, titre}) de toutes les parties, peu importe l'instance
  """
  @spec lister_parties() :: map()
  def lister_parties() do
    parties = for entree <- points_entree() do
      GenServer.call(entree, :lister_parties)
    end
    Enum.reduce(parties, &Map.merge/2)
  end

  @spec notifier_joueurs(integer()) :: :ok
  def notifier_joueurs(id) do
    Enum.each(:pg.get_members({:joueur, id}), fn joueur -> notifier_joueur(joueur) end)
  end

  @spec notifier_joueur(pid()) :: :actualiser
  def notifier_joueur(joueur) do
    send(joueur, :actualiser)
  end

  @doc """
  Ajoute un joueur dans une partie, notifie le processus appelant

  Cette fonction ajoute un joueur avec son nom dans la partie correspondante.
  Cette fonction ne tient pas compte de l'emplacement de la partie, qu'elle soit sur cette instance ou se le cluster.
  Le processus appelant `self/0` sera ajouté au groupe de la partie

  Paramètres :
    - `id` de la partie
    - `pid` de la partie
    - `nom` du joueur
  """
  @spec ajouter_joueur(integer(), pid(), String.t()) :: {:ok, integer}
  def ajouter_joueur(id, processus, nom) do
    entree = List.first(points_entree())
    resultat = GenServer.call(entree, {:ajouter_joueur, id, processus, nom})
    IO.inspect(resultat, label: "JEUUUUUUUUU")
    case resultat do
      {:ok, id_joueur} ->
        :pg.join({:joueur, id}, self())
        notifier_joueur(self())
        {:ok, id_joueur}
      :invalide -> :invalide
    end

  end

  @doc """
  Joue un coup dans une partie, notifie les joueurs de celle-ci

  Cette fonction permet au joueur (grace à son identifiant) de jouer un coup, également précisé en paramètre
  Cette opération ne tient pas non plus compte de l'emplacement de la partie

  Paramètres :
  - `id` de la partie
  - `pid` de la partie
  - `joueur` identifiant du joueur
  - `coup` le coup du joueur
  """
  @spec jouer(integer(), pid(), integer(), atom() | tuple()) :: :ok | :invalide
  def jouer(id, processus, joueur, coup) do
    entree = List.first(points_entree())
    resultat = GenServer.call(entree, {:jouer, id, processus, joueur, coup})
    resultat != :invalide && :ok || :invalide
  end




  @impl true
  def init(_) do
    :pg.join("cartes", self())
    {:ok, {0, %{}}}
  end

  @impl true
  def handle_call(:nombre_parties, _from, {identifiant_max, parties}) do
    {:reply, map_size(parties), {identifiant_max, parties}}
  end

  @impl true
  def handle_call({:creer_partie, regles}, _from, {identifiant_max, parties}) do
    identifiant = :erlang.phash2({node(), identifiant_max})
    IO.puts("#{node()}")
    {:ok, nouvelle_partie} =
      DynamicSupervisor.start_child(Partie.Superviseur, {Partie, {identifiant, regles}})
    parties = Map.put(parties, identifiant, {nouvelle_partie, regles.titre()})
    {:reply, {identifiant, nouvelle_partie}, {identifiant_max + 1, parties}}
  end

  @impl true
  def handle_call({:trouver_partie, identifiant}, _from, {indentifiant_max, parties}) do
    {partie, _} = Map.get(parties, identifiant, {nil, nil})
    {:reply, partie, {indentifiant_max, parties}}
  end

  @impl true
  def handle_call(:lister_parties, _from, {identifiant_max, parties}) do
    {:reply, parties, {identifiant_max, parties}}
  end

  @impl true
  def handle_call({:ajouter_joueur ,id, processus, nom}, _from, {identifiant_max, parties}) do
    resultat = Partie.ajouter_joueur(processus, nom)

    if resultat != :invalide do
      notifier_joueurs(id)
    end
    {:reply, resultat, {identifiant_max, parties}}
  end

  @impl true
  def handle_call({:jouer, id, processus, joueur, coup}, _from, {identifiant_max, parties}) do
    resultat = Partie.jouer(processus, joueur, coup)

    if resultat != :invalide do
      notifier_joueurs(id)
    end

    {:reply, resultat, {identifiant_max, parties}}
  end

  @impl true
  def handle_call(:entree, _from, {identifiant_max, parties}) do
    entree = points_entree()
    if map_size(entree) == 0 do
      {:reply, false, {identifiant_max, parties}}
    else
      {:reply, true, {identifiant_max, parties}}
    end
  end

  @spec points_entree() :: [pid()]
  def points_entree() do
    :pg.get_members("cartes")
  end
end