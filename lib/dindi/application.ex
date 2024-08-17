defmodule Dindi.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      DindiWeb.Telemetry,
      Dindi.Repo,
      {DNSCluster, query: Application.get_env(:dindi, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: Dindi.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: Dindi.Finch},
      # Start a worker by calling: Dindi.Worker.start_link(arg)
      # {Dindi.Worker, arg},
      # Start to serve requests, typically the last entry
      DindiWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Dindi.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    DindiWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
