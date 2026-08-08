defmodule Terra.Repo.Migrations.CreateQuestions do
  use Ecto.Migration

  def change do
    create table(:questions, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :survey_id, references(:surveys, type: :binary_id, on_delete: :delete_all), null: false
      add :type, :string, null: false, default: "text"
      add :title, :string, null: false
      add :position, :integer, null: false, default: 0
      add :required, :boolean, default: false, null: false
      timestamps()
    end

    create index(:questions, [:survey_id])
  end
end
