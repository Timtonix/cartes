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
    ecran = Console.Ecran.NomJoueur.new()

    if Jeu.peut_communiquer?() do
      afficher_retour(ecran, :rafraichir)
      {:ok, ecran}
    else
      IO.puts("Impossible de contacter un application `carte`")
      {:stop, ecran}
    end
  end

  @impl true
  def handle_call({:entree, entree}, _from, ecran) do
    module = ecran.__struct__
    retour = module.gerer_entree(ecran, entree)
    ecran = afficher_retour(ecran, retour)
    {:reply, :ok, ecran}
  end

  defp afficher_ecran(ecran, message \\ "", seulement_prompt \\ false) do
    module = ecran.__struct__
    titre = module.titre(ecran)
    texte = module.texte(ecran)
    prompt = module.prompt(ecran)

    complet = """
    #{(seulement_prompt && "") || titre}

    #{(seulement_prompt && "") || String.trim(texte)}
    #{message}
    #{prompt}
    """
    IO.puts(String.trim(complet))
    ecran
  end

  defp afficher_retour(ecran, :silence), do: ecran

  defp afficher_retour(ecran, :prompt) do
    afficher_ecran(ecran, "", true)
  end

  defp afficher_retour(ecran, :rafraichir) do
    afficher_ecran(ecran)
  end

  defp afficher_retour(ecran, {:prompt, retour}) do
    afficher_ecran(ecran, retour, true)
  end

  defp afficher_retour(ecran, {:rafraichir, retour}) do
    afficher_ecran(ecran, retour)
  end

  defp afficher_retour(_, ecran) do
    afficher_retour(ecran, :rafraichir)
  end


end
