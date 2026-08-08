defmodule TerraWeb.Api.ResponseController do
  use TerraWeb, :controller

  alias Terra.{Surveys, Responses, Questions}

  @doc """
  Returns the published survey with its questions and options for taking.
  This is the API counterpart to the LiveView at GET /s/:slug.
  """
  def show(conn, %{"slug" => slug}) do
    survey = Surveys.get_survey_by_slug!(slug)
    questions = Questions.list_questions(survey.id)

    json(conn, %{
      survey: %{
        id: survey.id,
        title: survey.title,
        slug: survey.slug,
        published: survey.published,
        theme: survey.theme
      },
      questions: Enum.map(questions, fn q ->
        %{
          id: q.id,
          type: q.type,
          title: q.title,
          position: q.position,
          required: q.required,
          options: Enum.map(q.options || [], fn o ->
            %{
              id: o.id,
              label: o.label,
              position: o.position,
              next_question_id: o.next_question_id
            }
          end)
        }
      end)
    })
  end

  def create(conn, %{"slug" => slug, "answers" => answers}) do
    survey = Surveys.get_survey_by_slug!(slug)

    case Responses.submit_response(survey.id, answers) do
      {:ok, response} ->
        conn
        |> put_status(:created)
        |> json(%{id: response.id, survey_id: response.survey_id})
      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> json(%{errors: format_errors(changeset)})
    end
  end

  defp format_errors(changeset) do
    Ecto.Changeset.traverse_errors(changeset, fn {msg, opts} ->
      Enum.reduce(opts, msg, fn {key, value}, acc ->
        String.replace(acc, "%{#{key}}", to_string(value))
      end)
    end)
  end
end
