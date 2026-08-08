defmodule TerraWeb.SurveyResultsLive do
  use TerraWeb, :live_view

  alias Terra.{Surveys, Responses, Questions}

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _url, socket) do
    survey = Surveys.get_user_survey!(socket.assigns.current_user.id, id)
    questions = Questions.list_questions(survey.id)
    responses = Responses.list_responses(survey.id)
    total = length(responses)

    aggregations = for q <- questions do
      {q, aggregate_question(q, responses)}
    end

    {:noreply,
     socket
     |> assign(:survey, survey)
     |> assign(:questions, questions)
     |> assign(:responses, responses)
     |> assign(:total, total)
     |> assign(:aggregations, aggregations)
     |> assign(:page_title, "#{survey.title} — Results")
    }
  end

  defp aggregate_question(question, responses) do
    pos_key = to_string(question.position)

    all_answers =
      responses
      |> Enum.map(fn r ->
        r.answers[pos_key]
      end)
      |> Enum.reject(&is_nil(&1))

    case question.type do
      "text" ->
        %{type: :text, answers: all_answers}

      "rating" ->
        ratings = all_answers |> Enum.map(fn v -> parse_rating(v) end) |> Enum.reject(&is_nil(&1))
        avg = if length(ratings) > 0, do: Enum.sum(ratings) / length(ratings), else: 0
        distribution =
          1..5
          |> Enum.map(fn r ->
            count = Enum.count(ratings, &(&1 == r))
            pct = if length(ratings) > 0, do: count / length(ratings) * 100, else: 0
            {r, count, pct}
          end)
        %{type: :rating, average: avg, distribution: distribution}

      "multiple_choice" ->
        options = question.options
        counts =
          options
          |> Enum.map(fn opt ->
            count = Enum.count(all_answers, &(&1 == opt.label))
            pct = if length(all_answers) > 0, do: count / length(all_answers) * 100, else: 0
            {opt.label, count, pct}
          end)
        %{type: :choice, counts: counts}
    end
  end

  defp parse_rating(str) when is_binary(str), do: String.to_integer(str)
  defp parse_rating(int) when is_integer(int), do: int
  defp parse_rating(_), do: nil
end
