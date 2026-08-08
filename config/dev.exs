import Config

secret_key_base =
  System.get_env("SECRET_KEY_BASE", "cenius-terra-dev-a1b2c3d4e5f6a7b8c9d0e1f2a3b4c5d6")

config :terra, TerraWeb.Endpoint,
  http: [ip: {0, 0, 0, 0}, port: String.to_integer(System.get_env("PORT", "4000"))],
  debug_errors: true,
  code_reloader: true,
  check_origin: false,
  secret_key_base: secret_key_base,
  watchers: []

config :terra, Terra.Repo,
  database: Path.expand("../terra_dev.db", __DIR__)

config :logger, :console, format: "[$level] $message\n"

config :phoenix, :stacktrace_depth, 20

config :phoenix, :plug_init_mode, :runtime
