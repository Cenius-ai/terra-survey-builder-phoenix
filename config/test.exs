import Config

secret_key_base =
  System.get_env("SECRET_KEY_BASE", "cenius-terra-test-b1c2d3e4f5a6b7c8d9e0f1a2b3c4d5e6")

config :terra, Terra.Repo,
  database: Path.expand("../terra_test.db", __DIR__),
  pool: Ecto.Adapters.SQL.Sandbox,
  pool_size: 1

config :terra, TerraWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: secret_key_base,
  server: false

config :logger, level: :warning
