defmodule TerraWeb.UserSessionController do
  use TerraWeb, :controller

  alias Terra.Accounts
  alias TerraWeb.UserAuth

  def create(conn, %{"email" => email, "password" => password}) do
    case Accounts.get_user_by_email_and_password(email, password) do
      nil ->
        conn
        |> put_flash(:error, "Invalid email or password")
        |> redirect(to: "/login")

      user ->
        conn
        |> UserAuth.log_in_user(user)
        |> put_flash(:info, "Welcome back!")
        |> redirect(to: "/")
    end
  end

  def delete(conn, _params) do
    conn
    |> UserAuth.log_out_user()
    |> put_flash(:info, "Logged out successfully.")
    |> redirect(to: "/")
  end
end
