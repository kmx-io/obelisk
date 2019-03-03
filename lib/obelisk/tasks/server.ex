defmodule Obelisk.Tasks.Server do
  @moduledoc """
  This task starts the Obelisk server

  ## Switches

  None.
  """

  def run(_) do
    Application.start(:plug_cowboy)
    IO.puts("Starting Cowboy server. Browse to http://localhost:4000/")
    IO.puts("Press <CTRL+C> <CTRL+C> to quit.")
    {:ok, pid} = Plug.Cowboy.http(Obelisk.Plug.Server, [])

    :timer.sleep(:infinity)
  end
end
