defmodule Terra.Accounts do
  import Ecto.Query, warn: false
  alias Terra.Repo
  alias Terra.User

  def get_user!(id) do
    Repo.get!(User, id)
  end

  def get_user_by_email(email) do
    Repo.get_by(User, email: email)
  end

  def get_user_by_email_and_password(email, password)
      when is_binary(email) and is_binary(password) do
    user = get_user_by_email(email)
    if user && Bcrypt.verify_pass(password, user.password_hash), do: user
  end

  def create_user(attrs \\ %{}) do
    %User{}
    |> User.changeset(attrs)
    |> Repo.insert()
  end
end
