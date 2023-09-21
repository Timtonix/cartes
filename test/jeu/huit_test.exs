defmodule JeuHuitTest do
  use ExUnit.Case
  doctest Jeu.Huit

  test "Ajouter un joueur" do
    jeu = Jeu.Huit.new()
    {jeu, id} = Jeu.Huit.ajouter_joueur(jeu, "Timothé")
    assert jeu.noms[id] == "Timothé"
  end

  test "Le joueur ne peut pas jouer car ce n'est pas son tour." do
    jeu = Jeu.Huit.new()
    {jeu, _} = Jeu.Huit.ajouter_joueur(jeu, "Jean-Pierre")
    # Le joueur 1 n'est pas :actuel
    assert Jeu.Huit.jouer?(jeu, 1, :piocher) == false
  end

  test "Le joueur ne peut pas jouer un carte qu'il n'a pas" do
    jeu = Jeu.Huit.new()
    {jeu, id} = Jeu.Huit.ajouter_joueur(jeu, "Jean-Pierre")
    mains = %{id => Pile.new()}
    jeu = %{jeu | mains: mains}
    assert Jeu.Huit.jouer?(jeu, id, {:jouer, "10", "trèfle"}) == false
  end

  test "Un joueur qui a une carte de la même valeur que celle visible peut la jouer mais ne peux pas piocher" do
    jeu = %Jeu.Huit{visible: Carte.new("5", "trèfle")}
    {jeu, id} = Jeu.Huit.ajouter_joueur(jeu, "Jean-Pierre")
    mains = %{id => Pile.new() |> Pile.ajouter("5", "carreau")}
    jeu = %{jeu | mains: mains}

    assert Jeu.Huit.jouer?(jeu, id, {:jouer, "10", "carreau"}) == true
    assert Jeu.Huit.jouer?(jeu, id, :piocher) == false

  end

  test "Un joueur peut toujours jouer un 8, et il n'a pas le droit de piocher" do
    jeu = %Jeu.Huit{visible: Carte.new("5", "trèfle")}
    {jeu, id} = Jeu.Huit.ajouter_joueur(jeu, "Jean-Pierre")
    mains = %{id => Pile.new() |> Pile.ajouter("8", "carreau")}
    jeu = %{jeu | mains: mains}

    assert Jeu.Huit.jouer?(jeu, id, {:jouer, "8", "carreau"}) == true
    assert Jeu.Huit.jouer?(jeu, id, :piocher) == false

  end
end