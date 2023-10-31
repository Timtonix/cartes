defmodule Carte.Application do
  use Application

  def start(_type, _args) do
    children = [
      {Registry, keys: :unique, name: Partie.Registre},
      {DynamicSupervisor, strategy: :one_for_one, name: Partie.Superviseur}
    ]

    opts = [strategy: :one_for_one, name: Carte.Superviseur]
    Supervisor.start_link(children, opts)
  end
  
end
