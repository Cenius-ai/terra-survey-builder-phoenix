defmodule Terra.Survey do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "surveys" do
    field :title, :string
    field :slug, :string
    field :published, :boolean, default: false
    field :theme, :map, default: %{}

    belongs_to :user, Terra.User
    has_many :questions, Terra.Question, on_delete: :delete_all
    has_many :responses, Terra.Response, on_delete: :delete_all

    timestamps()
  end

  def changeset(survey, attrs) do
    survey
    |> cast(attrs, [:title, :slug, :published, :theme, :user_id])
    |> validate_required([:title])
    |> unique_constraint(:slug)
    |> maybe_generate_slug()
  end

  defp maybe_generate_slug(changeset) do
    if get_field(changeset, :slug) do
      changeset
    else
      title = get_field(changeset, :title)
      if title do
        slug = title |> String.downcase() |> String.replace(~r/[^a-z0-9]+/, "-") |> String.trim("-")
        put_change(changeset, :slug, slug)
      else
        changeset
      end
    end
  end
end
