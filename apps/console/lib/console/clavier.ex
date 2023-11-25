defmodule Console.Clavier do
  @moduledoc """
  Une tache qui gère les entrées claviers
  """

  use Task

  @doc """
  Création du processus
  """
  def start_link(options) do
    Task.start_link(__MODULE__, :ecouter_clavier, options)
  end

  def ecouter_clavier(_) do
    entree_clavier = IO.gets("") |> String.trim()
    Console.Interface.gerer_entree(entree_clavier)
    ecouter_clavier(nil)
  end

end
