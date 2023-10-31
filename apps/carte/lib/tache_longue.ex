defmodule TacheLongue do
  @moduledoc false
  @spec lancer() :: pid()
  def lancer() do
    origine = self()
    spawn(fn -> executer(origine) end)
  end

  @spec executer(pid()) :: {:result, number()}
  def executer(origine) do
    Process.sleep(2_000)
    send(origine, {:result, 1+7+8})
  end
end
