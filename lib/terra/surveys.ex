defmodule Terra.Surveys do
  import Ecto.Query, warn: false
  alias Terra.Repo
  alias Terra.Survey

  @doc """
  Lists all surveys (public — used on home page).
  """
  def list_surveys do
    Survey
    |> order_by(desc: :inserted_at)
    |> Repo.all()
    |> Repo.preload(:questions)
  end

  @doc """
  Lists surveys owned by a specific user (auth-only listing).
  """
  def list_user_surveys(user_id) do
    Survey
    |> where([s], s.user_id == ^user_id)
    |> order_by(desc: :inserted_at)
    |> Repo.all()
    |> Repo.preload(:questions)
  end

  @doc """
  Gets a survey by ID with no ownership check (public routes only).
  """
  def get_survey!(id) do
    Survey
    |> Repo.get!(id)
    |> Repo.preload(questions: [:options])
  end

  @doc """
  Gets a survey scoped by owner. Returns nil if the survey belongs to another user.
  Used by all protected routes to enforce ownership (IDOR prevention).
  """
  def get_user_survey(user_id, survey_id) do
    Survey
    |> where([s], s.id == ^survey_id and s.user_id == ^user_id)
    |> Repo.one()
    |> case do
      nil -> nil
      survey -> Repo.preload(survey, questions: [:options])
    end
  end

  @doc """
  Same as get_user_survey/2 but raises Ecto.NoResultsError on missing or wrong owner.
  """
  def get_user_survey!(user_id, survey_id) do
    case get_user_survey(user_id, survey_id) do
      nil -> raise Ecto.NoResultsError, queryable: Survey
      survey -> survey
    end
  end

  @doc """
  Gets a published survey by slug (public — no ownership check).
  """
  def get_survey_by_slug!(slug) do
    Survey
    |> where([s], s.slug == ^slug and s.published == true)
    |> Repo.one!()
    |> Repo.preload(questions: [:options])
  end

  def create_survey(attrs \\ %{}) do
    %Survey{}
    |> Survey.changeset(attrs)
    |> Repo.insert()
  end

  def update_survey(%Survey{} = survey, attrs) do
    survey
    |> Survey.changeset(attrs)
    |> Repo.update()
  end

  def delete_survey(%Survey{} = survey) do
    Repo.delete(survey)
  end

  def publish_survey(%Survey{} = survey) do
    survey
    |> Survey.changeset(%{published: !survey.published})
    |> Repo.update()
  end

  def change_survey(%Survey{} = survey, attrs \\ %{}) do
    Survey.changeset(survey, attrs)
  end
end
