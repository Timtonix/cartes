defmodule Console.Ecran do
  @moduledoc """
  Abstraction décrivant un écran.
  Un écran est un module indiquant l’action actuelle du joueur. L’écran est donc un
  point dans l’expérience utilisateur. Il est possible
  de se déplacer d’écran en écran en utilisant le retour
  de `gérer_entrée` ou d’une des autres fonctions du module.
  Un écran est responsable :
  - D’afficher des informations propres à l’expérience utilisateur spécifique ;
  - De gérer les entrées utilisateurs qui pourraient survenir quand cet écran est
  actif.
  """

  @typedoc """
  Un atom pour indiquer à l'interface l'action à effectuer qaund un raccourci clavier est intercepté.
  """
  @type action_entree :: :silent | :prompt | :rafraichir

  @typedoc """
  Un retour possible lors de l'interception d'un raccourci clavier
  """
  @type retour_clavier() :: action_entree | {action_entree, String.t()} | struct()

  @doc """
  Retourne le titre de l’écran.
  """
  @callback titre(struct()) :: String.t()
  @doc """
  Retourne le texte de l’écran.
  """
  @callback texte(struct()) :: String.t()
  @doc """
  Retourne le prompt de l’écran (le texte tout en bas, indiquant quelle information
  est à préciser ici).
  """
  @callback prompt(struct()) :: String.t()

  @doc """
  Gère les entrées claviers de l’utilisateur.
  Cette fonction peut retourner plusieurs informations :
  - `:silence` : indique à l’interface qu’il n’est pas nécessaire d’afficher l’écran
  de novueau ;
  - `:prompt` : indique à l’interface qu’il est simplement nécessaire d’afficher de
  nouveau le prompt de l’écran, sans son texte ;
  - `:rafraîchir` : indique à l’interface qu’il faut afficher tout l’écran (titre,
  texte et prompt) ;
  - `{atome, texte}` : où `atome` est l’un des trois atomes ci-dessus et `texte` est
  le texte à afficher ;
  - `écran` : où `écran` est l
  """
  @callback gerer_entree(struct(), String.t()) :: retour_clavier()
end