import Config

config :terra,
  ecto_repos: [Terra.Repo],
  generators: [binary_id: true]

# Signing salts: read from env vars in production; use deterministic dev fallbacks
# so the value stays stable between compile-time and runtime evaluation.
session_signing_salt =
  System.get_env("SESSION_SIGNING_SALT") ||
    Base.encode16(:crypto.hash(:sha256, "terra-dev-session-salt-v2-2026"))

live_view_signing_salt =
  System.get_env("LIVE_VIEW_SIGNING_SALT") ||
    Base.encode16(:crypto.hash(:sha256, "terra-dev-liveview-salt-v2-2026"))

config :terra, TerraWeb.Endpoint,
  url: [host: "localhost"],
  signing_salt: session_signing_salt,
  render_errors: [
    formats: [html: TerraWeb.ErrorHTML, json: TerraWeb.ErrorJSON],
    layout: false
  ],
  pubsub_server: Terra.PubSub,
  live_view: [signing_salt: live_view_signing_salt]

config :phoenix, :json_library, Jason

config :esbuild,
  version: "0.24.0",
  terra: [
    args: ~w(js/app.js --bundle --target=es2017 --outdir=../priv/static/assets --external:/fonts/* --external:/images/*),
    cd: Path.expand("../assets", __DIR__),
    env: %{"NODE_PATH" => Path.expand("../deps", __DIR__)}
  ]

config :tailwind,
  version: "3.4.17",
  terra: [
    args: ~w(
      --config=tailwind.config.js
      --input=css/app.css
      --output=../priv/static/assets/app.css
    ),
    cd: Path.expand("../assets", __DIR__)
  ]

import_config "#{config_env()}.exs"
