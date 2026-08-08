defmodule Terra.Repo.Migrations.AddUserIdToSurveys do
  use Ecto.Migration

  def change do
    alter table(:surveys) do
      add :user_id, :binary_id
    end

    create index(:surveys, [:user_id])
  end
end
