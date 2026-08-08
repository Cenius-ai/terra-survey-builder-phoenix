defmodule TerraWeb.Endpoint do
  use Phoenix.Endpoint, otp_app: :terra

  @session_options [
    store: :cookie,
    key: "_terra_key",
    signing_salt: Application.compile_env!(:terra, [TerraWeb.Endpoint, :signing_salt])
  ]

  socket "/live", Phoenix.LiveView.Socket,
    websocket: [connect_info: [session: @session_options]]

  plug Plug.Static,
    at: "/",
    from: :terra,
    gzip: false,
    only: TerraWeb.static_paths()

  if code_reloading? do
    socket "/phoenix/live_reload/socket", Phoenix.LiveReloader.Socket
    plug Phoenix.LiveReloader
    plug Phoenix.CodeReloader
  end

  plug Plug.RequestId
  plug Plug.Telemetry, event_prefix: [:phoenix, :endpoint]

  plug Plug.Parsers,
    parsers: [:urlencoded, :multipart, :json],
    pass: ["*/*"],
    json_decoder: Phoenix.json_library()

  plug Plug.MethodOverride
  plug Plug.Head

  plug Plug.Session, @session_options

  plug TerraWeb.Router
end
