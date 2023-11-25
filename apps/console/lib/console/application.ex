defmodule Console.Application do
  def start(_type, _args) do
    IO.puts("Start CONSOLE")
    topologies = Application.get_env(:libcluster, :topologies)
    children = [
      {Cluster.Supervisor, [topologies, [name: Carte.ClusterSupervisor]]},
      %{id: :pg, start: {:pg, :start_link, []}},
      Console.Interface,
      Console.Clavier
    ]

    opts = [strategy: :one_for_one, name: Console.Supervisor]
    IO.inspect(opts)
    Supervisor.start_link(children, opts)
  end
end
