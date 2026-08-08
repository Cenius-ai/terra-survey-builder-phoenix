defmodule Terra.Repo.Migrations.CreateResponses do
  use Ecto.Migration

  def change do
    create table(:responses, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :survey_id, references(:surveys, type: :binary_id, on_delete: :delete_all), null: false
      add :answers, :map, null: false, default: %{}
      timestamps()
    end

    create index(:responses, [:survey_id])
  end
end
