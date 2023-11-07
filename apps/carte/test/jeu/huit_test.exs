defmodule JeuHuitTest do
  use ExUnit.Case
  doctest Jeu.Huit

  test "Créer un jeu" do
    jeu = Jeu.Huit.new()
    assert length(jeu.pioche.cartes) == 51
    assert length(jeu.defausse.cartes) == 1
  end

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

    assert Jeu.Huit.jouer?(jeu, id, {:jouer, "5", "carreau"}) == true
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

  test "Quand un joueur joue un deux, le suivant pioche 2 cartes" do
    pioche = Pile.new() |> Pile.ajouter("3", "pique") |> Pile.ajouter("valet", "coeur")
    mains = %{
      0 => Pile.new() |> Pile.ajouter("2", "trèfle"),
      1 => Pile.new(),
      2 => Pile.new()
    }
    visible = Carte.new("7", "carreau")
    jeu = %Jeu.Huit{mains: mains, pioche: pioche, visible: visible}
    jeu = Jeu.Huit.jouer(jeu, 0, {:jouer, "2", "trèfle"})
    assert {"2", "trèfle"} in jeu.mains[0] == false
    assert {"2", "trèfle"} in jeu.defausse == true
    assert jeu.actuel == 2
    assert Pile.taille(jeu.mains[1]) == 2
    assert jeu.visible == %Carte{enseigne: "trèfle", valeur: "2"}
  end

  test "Quand un joueur joue un un valet le suivant passe son tour" do
    pioche = Pile.new() |> Pile.ajouter("3", "pique") |> Pile.ajouter("7", "coeur")
    mains = %{
      0 => Pile.new() |> Pile.ajouter("valet", "trèfle"),
      1 => Pile.new(),
      2 => Pile.new()
    }
    visible = Carte.new("7", "carreau")
    jeu = %Jeu.Huit{mains: mains, pioche: pioche, visible: visible}
    jeu = Jeu.Huit.jouer(jeu, 0, {:jouer, "valet", "trèfle"})
    assert {"valet", "trèfle"} in jeu.mains[0] == false
    assert {"valet", "trèfle"} in jeu.defausse == true
    assert jeu.actuel == 2
    assert Pile.taille(jeu.mains[1]) == 0
    assert jeu.visible == %Carte{enseigne: "trèfle", valeur: "valet"}
  end

  test "Quand un joueur joue un as, on change le sens" do
    pioche = Pile.new() |> Pile.ajouter("3", "pique") |> Pile.ajouter("7", "coeur")
    mains = %{
      0 => Pile.new() |> Pile.ajouter("as", "trèfle"),
      1 => Pile.new() |> Pile.ajouter("roi", "trèfle"),
      2 => Pile.new() |> Pile.ajouter("1", "carreau")
    }
    visible = Carte.new("7", "carreau")
    jeu = %Jeu.Huit{mains: mains, pioche: pioche, visible: visible}
    jeu = Jeu.Huit.jouer(jeu, 0, {:jouer, "as", "trèfle"})
    assert {"as", "trèfle"} in jeu.mains[0] == false
    assert {"as", "trèfle"} in jeu.defausse == true
    assert jeu.actuel == 2
    assert Pile.taille(jeu.mains[2]) == 1
    assert jeu.sens == :inverse
    assert jeu.visible == %Carte{enseigne: "trèfle", valeur: "1"}
    assert Jeu.Huit.jouer?(jeu, jeu.actuel, {:jouer, "1", "carreau"}) == true
    jeu = Jeu.Huit.jouer(jeu, jeu.actuel, {:jouer, "1", "carreau"})
    assert jeu.actuel == 0
    assert jeu.sens == :ordinaire
  end

  test "Jouer un carte normale" do
    pioche = Pile.new() |> Pile.ajouter("3", "pique") |> Pile.ajouter("7", "coeur")
    mains = %{
      0 => Pile.new() |> Pile.ajouter("5", "trèfle"),
      1 => Pile.new() |> Pile.ajouter("roi", "trèfle"),
      2 => Pile.new() |> Pile.ajouter("9", "carreau")
    }
    visible = Carte.new("7", "carreau")
    jeu = %Jeu.Huit{mains: mains, pioche: pioche, visible: visible}
    assert Jeu.Huit.jouer?(jeu, 0, {:jouer, "5", "trèfle"}) == false
    jeu = Jeu.Huit.jouer(jeu, 0, {:jouer, "5", "trèfle"})
    assert jeu.visible == %Carte{enseigne: "trèfle", valeur: "5"}
    assert jeu.actuel == 1
  end

  test "Un joueur peu piocher" do
    pioche = Pile.new() |> Pile.ajouter("3", "pique") |> Pile.ajouter("7", "coeur")
    mains = %{
      0 => Pile.new() |> Pile.ajouter("5", "trèfle"),
      1 => Pile.new() |> Pile.ajouter("roi", "trèfle"),
      2 => Pile.new() |> Pile.ajouter("9", "carreau")
    }
    visible = Carte.new("7", "carreau")
    jeu = %Jeu.Huit{mains: mains, pioche: pioche, visible: visible}
    assert Jeu.Huit.jouer?(jeu, 0, :piocher) == true
    jeu = Jeu.Huit.jouer(jeu, 0, :piocher)
    assert jeu.visible == %Carte{enseigne: "carreau", valeur: "7"}
    assert jeu.actuel == 1
  end
end