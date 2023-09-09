defmodule Jeu.Huit do
  @moduledoc """
  Implémentation du jeu de 8 américain.
  """
  @behaviour Regles
defstruct actuel: 0, defausse: Pile.new(), mains: %{}, noms: %{},
    pioche: Pile.new(), sens: ordinaire, visible: nil

@typedoc "Un jeu de 8 américain"
@type t() :: %{
  actuel: integer(),
  defausse: Pile.t(),
  mains: %{integer() => Pile.t()},
  noms: %{integer(), String.t()}
  pioche: String.t()
  sens: :ordinaire | :inverse,
  visible: Carte.t()
             }
end