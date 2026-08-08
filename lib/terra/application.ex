defmodule Terra.Application do
  use Application

  @impl true
  def start(_type, _args) do
    children = [
      Terra.Repo,
      {Phoenix.PubSub, name: Terra.PubSub},
      TerraWeb.Endpoint
    ]

    opts = [strategy: :one_for_one, name: Terra.Supervisor]
    Supervisor.start_link(children, opts)
  end

  @impl true
  def config_change(changed, _new, removed) do
    TerraWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
