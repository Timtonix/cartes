defmodule Carte.Application do
  use Application

  def start(_type, _args) do
    children = [
      %{id: :pg, start: {:pg, :start_link, []}},
      {Registry, keys: :unique, name: Partie.Registre},
      {DynamicSupervisor, strategy: :one_for_one, name: Partie.Superviseur},
      Jeu
    ]

    opts = [strategy: :one_for_one, name: Carte.Superviseur]
    Supervisor.start_link(children, opts)
  end
  
end
