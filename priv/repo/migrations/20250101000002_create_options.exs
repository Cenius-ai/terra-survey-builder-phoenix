defmodule Terra.Repo.Migrations.CreateOptions do
  use Ecto.Migration

  def change do
    create table(:options, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :question_id, references(:questions, type: :binary_id, on_delete: :delete_all), null: false
      add :label, :string, null: false
      add :position, :integer, null: false, default: 0
      add :next_question_id, references(:questions, type: :binary_id, on_delete: :nilify_all)
      timestamps()
    end

    create index(:options, [:question_id])
  end
end
