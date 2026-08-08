defmodule Terra.Response do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "responses" do
    field :answers, :map, default: %{}

    belongs_to :survey, Terra.Survey

    timestamps()
  end

  def changeset(response, attrs) do
    response
    |> cast(attrs, [:answers, :survey_id])
    |> validate_required([:answers, :survey_id])
  end
end
