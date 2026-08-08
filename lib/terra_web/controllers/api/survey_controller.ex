defmodule TerraWeb.Api.SurveyController do
  use TerraWeb, :controller

  alias Terra.{Surveys, Questions, Responses}

  def index(conn, _params) do
    user = conn.assigns.current_user
    surveys = Surveys.list_user_surveys(user.id)
    render(conn, :index, surveys: surveys)
  end

  def create(conn, %{"title" => title} = params) do
    user = conn.assigns.current_user
    attrs = %{title: title, user_id: user.id}
    attrs = if Map.has_key?(params, "published"), do: Map.put(attrs, :published, params["published"]), else: attrs
    attrs = if Map.has_key?(params, "theme"), do: Map.put(attrs, :theme, params["theme"]), else: attrs

    case Surveys.create_survey(attrs) do
      {:ok, survey} ->
        conn
        |> put_status(:created)
        |> render(:show, survey: survey)
      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> json(%{errors: format_errors(changeset)})
    end
  end

  def show(conn, %{"id" => id}) do
    user = conn.assigns.current_user
    survey = Surveys.get_user_survey!(user.id, id)
    questions = Questions.list_questions(survey.id)
    render(conn, :show, survey: survey, questions: questions)
  end

  def update(conn, %{"id" => id} = params) do
    user = conn.assigns.current_user
    survey = Surveys.get_user_survey!(user.id, id)
    attrs = Map.take(params, ["title", "published", "theme"])

    case Surveys.update_survey(survey, attrs) do
      {:ok, survey} ->
        render(conn, :show, survey: survey)
      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> json(%{errors: format_errors(changeset)})
    end
  end

  def delete(conn, %{"id" => id}) do
    user = conn.assigns.current_user
    survey = Surveys.get_user_survey!(user.id, id)
    {:ok, _} = Surveys.delete_survey(survey)
    send_resp(conn, :no_content, "")
  end

  def publish(conn, %{"id" => id}) do
    user = conn.assigns.current_user
    survey = Surveys.get_user_survey!(user.id, id)
    {:ok, survey} = Surveys.publish_survey(survey)
    render(conn, :show, survey: survey)
  end

  def questions(conn, %{"id" => id}) do
    user = conn.assigns.current_user
    _survey = Surveys.get_user_survey!(user.id, id)
    questions = Questions.list_questions(id)
    render(conn, "questions.json", questions: questions)
  end

  def results(conn, %{"id" => id}) do
    user = conn.assigns.current_user
    survey = Surveys.get_user_survey!(user.id, id)
    questions = Questions.list_questions(survey.id)
    responses = Responses.list_responses(survey.id)
    total = length(responses)

    aggregations = for q <- questions do
      pos_key = to_string(q.position)
      all_answers =
        responses
        |> Enum.map(fn r -> r.answers[pos_key] end)
        |> Enum.reject(&is_nil/1)
      {q, build_agg(q, all_answers)}
    end

    render(conn, "results.json",
      survey: survey,
      total: total,
      aggregations: aggregations,
      responses: responses
    )
  end

  defp build_agg(question, answers) do
    case question.type do
      "text" ->
        %{type: "text", answers: answers}
      "rating" ->
        ratings = answers |> Enum.map(&parse_rating/1) |> Enum.reject(&is_nil/1)
        avg = if length(ratings) > 0, do: Enum.sum(ratings) / length(ratings), else: 0
        %{type: "rating", average: Float.round(avg, 1), count: length(ratings)}
      "multiple_choice" ->
        counts = question.options |> Enum.map(fn opt ->
          count = Enum.count(answers, &(&1 == opt.label))
          %{label: opt.label, count: count}
        end)
        %{type: "choice", counts: counts}
    end
  end

  defp parse_rating(str) when is_binary(str), do: String.to_integer(str)
  defp parse_rating(int) when is_integer(int), do: int
  defp parse_rating(_), do: nil

  defp format_errors(changeset) do
    Ecto.Changeset.traverse_errors(changeset, fn {msg, opts} ->
      Enum.reduce(opts, msg, fn {key, value}, acc ->
        String.replace(acc, "%{#{key}}", to_string(value))
      end)
    end)
  end
end
