defmodule Joueur do
  @moduledoc """
  Crée un faux joueur !
  """

  use GenServer

  def start_link(id, process, nom) do
    GenServer.start_link(__MODULE__, {id, process, nom})
  end

  @impl true
  def init({id, process, nom}) do
    {:ok, joueur} = Jeu.ajouter_joueur(id, process, nom)
    {:ok, {id, process, joueur, nom}}
  end

  @impl true
  def handle_info(:actualiser, {id, process, joueur, nom})do
    condensee = Partie.condensee(process, joueur)
    IO.inspect(joueur, label: "JOUEUR")
    IO.inspect(condensee, label: "Le joueur #{nom} (#{joueur} dans la partie #{id} a été notifié)")
    {:noreply, {id, process, joueur, nom}}
  end
end
