defmodule Vereine.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      Plug.Cowboy.child_spec(scheme: :http, plug: Web.Router, options: [port: 4000]),
      {Registry, [keys: :duplicate, name: :event_stream]},
      CQRSComponents.AggregateSupervisor
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Vereine.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
