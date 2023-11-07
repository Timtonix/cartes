defmodule Console.Application do
  def start(_type, _args) do
    IO.puts("Start CONSOLE")
    topologies = Application.get_env(:libcluster, :topologies)
    children = [
      {Cluster.Supervisor, [topologies, [name: Carte.ClusterSupervisor]]},
      %{id: :pg, start: {:pg, :start_link, []}}
    ]

    opts = [strategy: :one_for_one, name: Console.Superviseur]
    Supervisor.start_link(children, opts)
  end
end