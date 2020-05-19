defmodule Vereine.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      # Starts a worker by calling: Vereine.Worker.start_link(arg)
      # {Vereine.Worker, arg}
      {Registry, [keys: :duplicate, name: :event_stream]},
      Web.OrganizationCache
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Vereine.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
