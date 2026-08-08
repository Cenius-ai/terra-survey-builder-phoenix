defmodule Terra.Questions do
  import Ecto.Query, warn: false
  alias Terra.Repo
  alias Terra.Question
  alias Terra.Option

  # ── Questions ──────────────────────────────────────────────────

  def list_questions(survey_id) do
    Question
    |> where([q], q.survey_id == ^survey_id)
    |> order_by(asc: :position)
    |> Repo.all()
    |> Repo.preload(:options)
  end

  def get_question!(id) do
    Question
    |> Repo.get!(id)
    |> Repo.preload(:options)
  end

  @doc """
  Gets a question scoped by owner via its survey. Returns nil if the survey
  belongs to a different user.
  """
  def get_user_question(user_id, question_id) do
    question = Repo.get(Question, question_id)
    if question do
      survey = Terra.Surveys.get_user_survey(user_id, question.survey_id)
      if survey, do: Repo.preload(question, :options)
    end
  end

  @doc """
  Same as get_user_question/2 but raises on missing or wrong owner.
  """
  def get_user_question!(user_id, question_id) do
    case get_user_question(user_id, question_id) do
      nil -> raise Ecto.NoResultsError, queryable: Question
      question -> question
    end
  end

  def create_question(survey_id, attrs \\ %{}) do
    max_pos =
      Question
      |> where([q], q.survey_id == ^survey_id)
      |> select([q], coalesce(max(q.position), -1))
      |> Repo.one!()

    attrs = Map.put(attrs, "position", Map.get(attrs, "position", max_pos + 1))

    %Question{}
    |> Question.changeset(Map.put(attrs, "survey_id", survey_id))
    |> Repo.insert()
  end

  def update_question(%Question{} = question, attrs) do
    question
    |> Question.changeset(attrs)
    |> Repo.update()
  end

  def delete_question(%Question{} = question) do
    Repo.delete(question)
  end

  def reorder_question(%Question{} = question, new_position) do
    question
    |> Question.changeset(%{position: new_position})
    |> Repo.update()
  end

  def change_question(%Question{} = question, attrs \\ %{}) do
    Question.changeset(question, attrs)
  end

  # ── Options ────────────────────────────────────────────────────

  def list_options(question_id) do
    Option
    |> where([o], o.question_id == ^question_id)
    |> order_by(asc: :position)
    |> Repo.all()
  end

  def get_option!(id) do
    Repo.get!(Option, id)
  end

  @doc """
  Gets an option scoped by owner via question → survey chain.
  Returns nil if the parent survey belongs to a different user.
  """
  def get_user_option(user_id, option_id) do
    option = Repo.get(Option, option_id)
    if option do
      question = Repo.get(Question, option.question_id)
      if question && Terra.Surveys.get_user_survey(user_id, question.survey_id) do
        option
      end
    end
  end

  @doc """
  Same as get_user_option/2 but raises on missing or wrong owner.
  """
  def get_user_option!(user_id, option_id) do
    case get_user_option(user_id, option_id) do
      nil -> raise Ecto.NoResultsError, queryable: Option
      option -> option
    end
  end

  def create_option(question_id, attrs \\ %{}) do
    max_pos =
      Option
      |> where([o], o.question_id == ^question_id)
      |> select([o], coalesce(max(o.position), -1))
      |> Repo.one!()

    attrs = Map.put(attrs, "position", Map.get(attrs, "position", max_pos + 1))

    %Option{}
    |> Option.changeset(Map.put(attrs, "question_id", question_id))
    |> Repo.insert()
  end

  def update_option(%Option{} = option, attrs) do
    option
    |> Option.changeset(attrs)
    |> Repo.update()
  end

  def delete_option(%Option{} = option) do
    Repo.delete(option)
  end

  def change_option(%Option{} = option, attrs \\ %{}) do
    Option.changeset(option, attrs)
  end
end
