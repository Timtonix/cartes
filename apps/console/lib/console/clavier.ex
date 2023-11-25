defmodule Console.Clavier do
  @moduledoc """
  Une tache qui gère les entrées claviers
  """

  use Task

  @doc """
  Création du processus
  """
  def start_link(options) do
    IO.inspect(options)
    # Le problème c'est que l'on transmet des options vides
    Task.start_link(__MODULE__, :ecouter_clavier, options)
  end

  def ecouter_clavier(_ \\ nil) do
    entree_clavier = IO.gets(">") |> String.trim()
    Console.Interface.gerer_entree(entree_clavier)
    ecouter_clavier(nil)
  end

end
