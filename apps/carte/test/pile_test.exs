defmodule PileTest do
  use ExUnit.Case
  doctest Pile

  test "vérifie l’ordre de Pile.ajouter" do
    cartes = [
      {"5", "trèfle"},
      {"1", "carreau"},
      {"roi", "pique"}
    ]
    # Crée une pile vide
    pile_vide = Pile.new()

    pile = Enum.reduce(cartes, pile_vide, fn {valeur, enseigne}, pile_courante -> Pile.ajouter(pile_courante, valeur, enseigne) end)

    cartes_dans_pile = for carte <- pile.cartes, do: {carte.valeur, carte.enseigne}
    assert Enum.reverse(cartes) == cartes_dans_pile
  end

end