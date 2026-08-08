defmodule Terra.Repo.Migrations.CreateSurveys do
  use Ecto.Migration

  def change do
    create table(:surveys, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :title, :string, null: false
      add :slug, :string, null: false
      add :published, :boolean, default: false, null: false
      add :theme, :map, default: %{}
      timestamps()
    end

    create unique_index(:surveys, [:slug])
  end
end
