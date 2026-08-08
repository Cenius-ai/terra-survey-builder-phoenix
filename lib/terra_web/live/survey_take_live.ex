defmodule TerraWeb.SurveyTakeLive do
  use TerraWeb, :live_view

  alias Terra.{Surveys, Responses}

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, answers: %{}, current_idx: 0, submitted: false, error: nil)}
  end

  @impl true
  def handle_params(%{"slug" => slug}, _url, socket) do
    survey = Surveys.get_survey_by_slug!(slug)
    questions = survey.questions |> Enum.sort_by(& &1.position)
    {:noreply,
     socket
     |> assign(:survey, survey)
     |> assign(:questions, questions)
     |> assign(:page_title, "#{survey.title} — Survey")
    }
  end

  @impl true
  def handle_event("answer", %{"question_id" => qid, "value" => value}, socket) do
    answers = Map.put(socket.assigns.answers, qid, value)
    questions = socket.assigns.questions
    current_idx = socket.assigns.current_idx
    current_q = Enum.at(questions, current_idx)

    # Validate required
    if current_q.required && (value == "" || is_nil(value)) do
      {:noreply, assign(socket, error: "This question is required")}
    else
      next_idx = compute_next_index(questions, current_idx, current_q, value)
      {:noreply, assign(socket, answers: answers, current_idx: next_idx, error: nil)}
    end
  end

  @impl true
  def handle_event("submit", _params, socket) do
    survey_id = socket.assigns.survey.id
    answers = socket.assigns.answers

    case Responses.submit_response(survey_id, answers) do
      {:ok, _response} ->
        {:noreply, assign(socket, submitted: true)}
      {:error, _} ->
        {:noreply, put_flash(socket, :error, "Failed to submit response.")}
    end
  end

  @impl true
  def handle_event("restart", _params, socket) do
    {:noreply, assign(socket, answers: %{}, current_idx: 0, submitted: false, error: nil)}
  end

  defp compute_next_index(questions, current_idx, current_q, value) do
    # Check if there is branching on this answer
    if current_q.type == "multiple_choice" do
      selected_option = Enum.find(current_q.options, &(&1.label == value))
      if selected_option && selected_option.next_question_id do
        next_q = Enum.find(questions, &(&1.id == selected_option.next_question_id))
        if next_q do
          Enum.find_index(questions, &(&1.id == next_q.id))
        else
          current_idx + 1
        end
      else
        current_idx + 1
      end
    else
      current_idx + 1
    end
  end
end
