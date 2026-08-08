# INSTALL

## 1. Prerequisites

- **Elixir `~> 1.15`** and Erlang/OTP. Verify with:
  ```bash
  elixir --version
  ```
- **Node.js** (for Tailwind CSS and esbuild asset compilation; install a current LTS release).
- **Git** (to clone the repository).

## 2. Clone the Repository

```bash
git clone <repository-url>
cd terra
```

## 3. Install Dependencies and Setup

Run the `setup` alias that fetches dependencies, creates the database, runs migrations, seeds demo data, and installs asset tooling:

```bash
mix setup
```

This executes the following steps (you can also run them individually):

```bash
mix deps.get                 # fetch Elixir dependencies
mix ecto.setup               # create, migrate, and seed the database
mix assets.setup             # install tailwind and esbuild if missing
```

## 4. Environment Variables

Copy the example environment file and adjust if needed:

```bash
cp .env.example .env
```

Open `.env` and set the secrets (`SECRET_KEY_BASE`, `LIVE_VIEW_SIGNING_SALT`, `SESSION_SIGNING_SALT`). Development defaults in `config/dev.exs` provide usable values, so this step is optional for local development.

## 5. Start the Development Server

```bash
mix phx.server
```

Visit [http://localhost:4000](http://localhost:4000). The server auto‑reloads when you change templates or stylesheets in development.

## 6. Running Tests

```bash
mix test
```

The test alias creates a test database (`terra_test.db`), runs migrations, and then executes the test suite.

## 7. Production Build

To create a production release:

```bash
MIX_ENV=prod mix release
```

**Note:** In production you must configure the environment variables listed in `.env.example` (especially `SECRET_KEY_BASE` and `PORT`) and ensure that the `priv/static` assets are included (they are compiled during the release step).

## 8. Troubleshooting

- **Elixir version mismatch** – ensure `elixir --version` reports `1.15.x`. Use a version manager like `asdf` or `kiex` if needed.
- **Asset compilation fails** – verify Node.js is installed and run `mix assets.setup` again.
- **Database file locked** – delete `terra_dev.db` (and the `-shm`/`-wal` files) and rerun `mix ecto.setup`.
- **Port already in use** – kill the process occupying port 4000 or set `PORT=4001` in `.env` before starting.