defmodule Console.Interface do
  @moduledoc """
  Un serveur générique créé de façon unique par application.
  Ce serveur est en charge des écrans (càd des différentes opérations possibles
  par le joueur en fonction de son expérience de jeu actuelle.
  """

  use GenServer

  @doc """
  Lance l'interface
  """
  def start_link(options \\ []) do
    options = Keyword.put(options, :name, :interface)
    GenServer.start_link(__MODULE__, options)
  end

  @doc """
  Gère les entrées de clavier de l'utilisateur
  L'entrée clavier est à préciser sous forme d'une chaine
  """
  @spec gerer_entree(String.t()) :: :ok
  def gerer_entree(entree) do
    GenServer.call(:interface, {:entree, entree})
  end

  @impl true
  def init(_) do
    {:ok, nil}
  end

  @impl true
  def handle_call({:entree, entree}, _from, ecran) do
    {r:reply, :ok, ecran}
  end
end
