defmodule JeuHuitTest do
  use ExUnit.Case
  doctest Jeu.Huit

  test "Ajouter un joueur" do
    jeu = Jeu.Huit.new()
    {jeu, id} = Jeu.Huit.ajouter_joueur(jeu, "Timothé")
    assert jeu.noms[id] == "Timothé"
  end
end