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

  @impl true
  def init(_) do
    {:ok, %{}}
  end
end