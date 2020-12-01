defmodule SensorHub.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      # Our I2C SensorHub reader process
      SensorHub.DataReader,
      # Start the Telemetry supervisor
      SensorHubWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: SensorHub.PubSub},
      # Start the Endpoint (http/https)
      SensorHubWeb.Endpoint
      # Start a worker by calling: SensorHub.Worker.start_link(arg)
      # {SensorHub.Worker, arg}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: SensorHub.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    SensorHubWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
