defmodule Carte.Application do
  use Application

  def start(_type, _args) do
    IO.puts("Start CARTE")
    topologies = Application.get_env(:libcluster, :topologies)
    children = [
      {Cluster.Supervisor, [topologies, [name: Carte.ClusterSupervisor]]},
      %{id: :pg, start: {:pg, :start_link, []}},
      {Registry, keys: :unique, name: Partie.Registre},
      {DynamicSupervisor, strategy: :one_for_one, name: Partie.Superviseur},
      Jeu
    ]

    opts = [strategy: :one_for_one, name: Carte.Supervisor]
    Supervisor.start_link(children, opts)
  end
  
end
