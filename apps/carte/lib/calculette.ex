defmodule Calculette do
  @moduledoc """
  Calculette un peu lente.
  Sa particularité est de prendre 2 secondes pour chaque calcul.
  Elle s’exécute dans un processus séparé. On doit la lancer
  en appelant la fonction `lancer`, qui retourne le PID que l’on
  doit conserver pour communiquer avec cette calculette.
  API :
  `lancer` : lance la calculette dans son processus.
  """
  # Fonctions de l’API utilisateur
  @doc """
  Lance la calculette dans son processus.
  Cette fonction retourne le PID qu’il faut conserver
  pour communiquer avec le processus.
  """
  @spec lancer() :: pid()
  def lancer do
    spawn(&écouter/0)
  end
  # Fonctions privées, exécutées dans le processus séparé.
  @spec écouter() :: number()
                     defp écouter do
                                  recevoir(0)
                                  end
  @spec recevoir(number()) :: number()
                         defp recevoir(total) do
                                              total =
                                              receive do
                                                      {:total, pid} -> envoyer_total(total, pid)
                                                      end
                                              recevoir(total)
                                              end
  @spec envoyer_total(number(), pid()) :: {:total, pid()}
                                                   defp envoyer_total(total, pid) do
                                                                                  send(pid, {:total, total})
                                                                                                          total
                                                                                  end
  # …
end