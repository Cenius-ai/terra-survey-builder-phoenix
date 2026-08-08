defmodule Terra.Option do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "options" do
    field :label, :string
    field :position, :integer
    field :next_question_id, :binary_id

    belongs_to :question, Terra.Question
    belongs_to :next_question, Terra.Question, foreign_key: :next_question_id, define_field: false

    timestamps()
  end

  def changeset(option, attrs) do
    option
    |> cast(attrs, [:label, :position, :next_question_id, :question_id])
    |> validate_required([:label, :question_id])
    |> validate_number(:position, greater_than_or_equal_to: 0)
  end
end
