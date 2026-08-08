defmodule TerraWeb.Api.SurveyJSON do
  def index(%{surveys: surveys}) do
    %{surveys: Enum.map(surveys, &survey_brief/1)}
  end

  def show(assigns) do
    survey = assigns.survey
    data = survey_full(survey)
    if Map.has_key?(assigns, :questions) do
      data = Map.put(data, :questions, Enum.map(assigns.questions, &question_json/1))
      %{survey: data}
    else
      %{survey: data}
    end
  end

  def questions(%{questions: questions}) do
    %{questions: Enum.map(questions, &question_json/1)}
  end

  def results(assigns) do
    %{
      survey: survey_brief(assigns.survey),
      total: assigns.total,
      aggregations: Enum.map(assigns.aggregations, fn {q, agg} ->
        %{question: question_json(q), aggregation: agg}
      end),
      responses: Enum.map(assigns.responses, fn r ->
        %{id: r.id, answers: r.answers, inserted_at: r.inserted_at}
      end)
    }
  end

  defp survey_brief(survey) do
    %{
      id: survey.id,
      title: survey.title,
      slug: survey.slug,
      published: survey.published,
      theme: survey.theme,
      inserted_at: survey.inserted_at,
      updated_at: survey.updated_at
    }
  end

  defp survey_full(survey) do
    brief = survey_brief(survey)
    qs = (Ecto.assoc_loaded?(survey.questions) && survey.questions) || []
    Map.put(brief, :questions, Enum.map(qs, &question_json/1))
  end

  defp question_json(question) do
    opts = (Ecto.assoc_loaded?(question.options) && question.options) || []
    %{
      id: question.id,
      survey_id: question.survey_id,
      type: question.type,
      title: question.title,
      position: question.position,
      required: question.required,
      options: Enum.map(opts, &option_json/1)
    }
  end

  defp option_json(option) do
    %{
      id: option.id,
      question_id: option.question_id,
      label: option.label,
      position: option.position,
      next_question_id: option.next_question_id
    }
  end
end
