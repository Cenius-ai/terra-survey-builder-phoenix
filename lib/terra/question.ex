defmodule Terra.Question do
  use Ecto.Schema
  import Ecto.Changeset

  @valid_types ~w(text multiple_choice rating)

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "questions" do
    field :type, :string, default: "text"
    field :title, :string
    field :position, :integer
    field :required, :boolean, default: false

    belongs_to :survey, Terra.Survey
    has_many :options, Terra.Option, on_delete: :delete_all

    timestamps()
  end

  def changeset(question, attrs) do
    question
    |> cast(attrs, [:type, :title, :position, :required, :survey_id])
    |> validate_required([:type, :title, :survey_id])
    |> validate_inclusion(:type, @valid_types)
    |> validate_number(:position, greater_than_or_equal_to: 0)
  end
end
