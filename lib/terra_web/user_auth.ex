defmodule TerraWeb.UserAuth do
  import Plug.Conn
  import Phoenix.Controller

  alias Terra.Accounts

  # ── Plug protocol ─────────────────────────────────────────────

  @doc false
  def init(action), do: action

  @doc false
  def call(conn, action) when is_atom(action) do
    apply(__MODULE__, action, [conn, []])
  end

  # ── Plugs for controller-based routes ──────────────────────────

  def fetch_current_user(conn, _opts) do
    user_id = get_session(conn, :user_id)
    user = if user_id, do: Accounts.get_user!(user_id)
    assign(conn, :current_user, user)
  end

  def require_authenticated_user(conn, _opts) do
    if conn.assigns[:current_user] do
      conn
    else
      conn
      |> put_flash(:error, "You must log in to access this page.")
      |> redirect(to: "/login")
      |> halt()
    end
  end

  def require_api_authenticated_user(conn, _opts) do
    if conn.assigns[:current_user] do
      conn
    else
      conn
      |> put_status(:unauthorized)
      |> json(%{error: "Authentication required"})
      |> halt()
    end
  end

  # ── Session helpers ────────────────────────────────────────────

  def log_in_user(conn, user) do
    conn
    |> put_session(:user_id, user.id)
    |> configure_session(renew: true)
  end

  def log_out_user(conn) do
    conn
    |> clear_session()
    |> configure_session(drop: true)
  end

  # ── LiveView on_mount hooks ────────────────────────────────────

  def on_mount(:fetch_current_user, _params, session, socket) do
    user_id = session["user_id"]
    user = if user_id, do: Accounts.get_user!(user_id)
    {:cont, Phoenix.Component.assign(socket, :current_user, user)}
  end

  def on_mount(:require_authenticated_user, _params, session, socket) do
    user_id = session["user_id"]

    if user_id do
      user = Accounts.get_user!(user_id)
      {:cont, Phoenix.Component.assign(socket, :current_user, user)}
    else
      {:halt, Phoenix.LiveView.redirect(socket, to: "/login")}
    end
  end
end
