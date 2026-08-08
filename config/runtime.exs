import Config

if config_env() == :prod do
  database_path =
    System.get_env("DATABASE_PATH") ||
      Path.expand("../terra_prod.db", __DIR__)

  config :terra, Terra.Repo,
    database: database_path,
    pool_size: String.to_integer(System.get_env("POOL_SIZE", "5"))

  secret_key_base =
    System.get_env("SECRET_KEY_BASE") ||
      raise "environment variable SECRET_KEY_BASE is missing."

  session_signing_salt =
    System.get_env("SESSION_SIGNING_SALT") ||
      raise "environment variable SESSION_SIGNING_SALT is missing."

  live_view_signing_salt =
    System.get_env("LIVE_VIEW_SIGNING_SALT") ||
      raise "environment variable LIVE_VIEW_SIGNING_SALT is missing."

  config :terra, TerraWeb.Endpoint,
    http: [ip: {0, 0, 0, 0}, port: String.to_integer(System.get_env("PORT", "4000"))],
    secret_key_base: secret_key_base,
    signing_salt: session_signing_salt,
    live_view: [signing_salt: live_view_signing_salt]
end
