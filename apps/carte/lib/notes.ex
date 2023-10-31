defmodule Note do
  use GenServer
  def start_link do
    # l'état du serveur (la liste vide) est en fait la liste de NOTE. On parle d'état pour définir ce qu'a un processus en mémoire
    GenServer.start_link(__MODULE__, [])
  end
  @impl true
  def init(notes) do
    {:ok, notes}
  end
  @impl true
  def handle_call({:ajouter, note}, _from, notes) do
    notes = [note | notes]
    {:reply, notes, notes}
  end
end

