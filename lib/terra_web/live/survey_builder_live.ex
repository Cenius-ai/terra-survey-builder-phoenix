defmodule TerraWeb.SurveyBuilderLive do
  use TerraWeb, :live_view

  alias Terra.{Surveys, Questions}

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, preview_mode: false)}
  end

  @impl true
  def handle_params(%{"id" => id}, _url, socket) do
    survey = Surveys.get_user_survey!(socket.assigns.current_user.id, id)
    questions = Questions.list_questions(survey.id)

    {:noreply,
     socket
     |> assign(:survey, survey)
     |> assign(:questions, questions)
     |> assign(:editing_question, nil)
     |> assign(:show_add_question, false)
     |> assign(:new_question_type, "text")
     |> assign(:preview_mode, false)
     |> assign(:page_title, "#{survey.title} — Builder")
    }
  end

  @impl true
  def handle_event("update_title", %{"title" => title}, socket) do
    case Surveys.update_survey(socket.assigns.survey, %{title: title}) do
      {:ok, survey} ->
        {:noreply, assign(socket, survey: survey, page_title: "#{survey.title} — Builder")}
      {:error, _} -> {:noreply, socket}
    end
  end

  @impl true
  def handle_event("add_question", %{"title" => title, "type" => type}, socket) do
    survey_id = socket.assigns.survey.id
    case Questions.create_question(survey_id, %{"title" => title, "type" => type}) do
      {:ok, _} ->
        {:noreply, assign(socket, questions: Questions.list_questions(survey_id), show_add_question: false, new_question_type: "text")}
      {:error, _} -> {:noreply, socket}
    end
  end

  @impl true
  def handle_event("delete_question", %{"id" => id}, socket) do
    question = Questions.get_question!(id)
    {:ok, _} = Questions.delete_question(question)
    questions = Questions.list_questions(socket.assigns.survey.id)
    editing = if socket.assigns.editing_question && socket.assigns.editing_question.id == id, do: nil, else: socket.assigns.editing_question
    {:noreply, assign(socket, questions: questions, editing_question: editing)}
  end

  @impl true
  def handle_event("edit_question", %{"id" => id}, socket) do
    {:noreply, assign(socket, editing_question: Questions.get_question!(id), show_add_question: false)}
  end

  @impl true
  def handle_event("update_question", %{"_id" => id, "title" => title, "type" => type, "required" => req}, socket) do
    question = Questions.get_question!(id)
    case Questions.update_question(question, %{"title" => title, "type" => type, "required" => req == "true"}) do
      {:ok, _} -> {:noreply, assign(socket, questions: Questions.list_questions(socket.assigns.survey.id), editing_question: nil)}
      {:error, _} -> {:noreply, socket}
    end
  end

  @impl true
  def handle_event("cancel_edit", _params, socket) do
    {:noreply, assign(socket, editing_question: nil, show_add_question: false)}
  end

  @impl true
  def handle_event("toggle_add_question", _params, socket) do
    {:noreply, assign(socket, show_add_question: !socket.assigns.show_add_question, editing_question: nil)}
  end

  @impl true
  def handle_event("select_type", %{"type" => type}, socket) do
    {:noreply, assign(socket, new_question_type: type)}
  end

  @impl true
  def handle_event("add_option", %{"question_id" => qid, "label" => label}, socket) do
    question = Questions.get_question!(qid)
    case Questions.create_option(question.id, %{"label" => label}) do
      {:ok, _} ->
        questions = Questions.list_questions(socket.assigns.survey.id)
        editing = if socket.assigns.editing_question, do: Questions.get_question!(socket.assigns.editing_question.id), else: nil
        {:noreply, assign(socket, questions: questions, editing_question: editing)}
      {:error, _} -> {:noreply, socket}
    end
  end

  @impl true
  def handle_event("delete_option", %{"id" => id}, socket) do
    option = Questions.get_option!(id)
    {:ok, _} = Questions.delete_option(option)
    questions = Questions.list_questions(socket.assigns.survey.id)
    editing = if socket.assigns.editing_question, do: Questions.get_question!(socket.assigns.editing_question.id), else: nil
    {:noreply, assign(socket, questions: questions, editing_question: editing)}
  end

  @impl true
  def handle_event("update_option", %{"id" => id, "label" => label, "next_question_id" => nqid}, socket) do
    option = Questions.get_option!(id)
    nqid_val = if nqid == "", do: nil, else: nqid
    case Questions.update_option(option, %{"label" => label, "next_question_id" => nqid_val}) do
      {:ok, _} ->
        questions = Questions.list_questions(socket.assigns.survey.id)
        editing = if socket.assigns.editing_question, do: Questions.get_question!(socket.assigns.editing_question.id), else: nil
        {:noreply, assign(socket, questions: questions, editing_question: editing)}
      {:error, _} -> {:noreply, socket}
    end
  end

  @impl true
  def handle_event("move_up", %{"id" => id}, socket) do
    question = Questions.get_question!(id)
    questions = socket.assigns.questions
    idx = Enum.find_index(questions, &(&1.id == question.id))
    if idx && idx > 0 do
      prev = Enum.at(questions, idx - 1)
      Questions.reorder_question(question, prev.position)
      Questions.reorder_question(prev, question.position)
    end
    {:noreply, assign(socket, questions: Questions.list_questions(socket.assigns.survey.id))}
  end

  @impl true
  def handle_event("move_down", %{"id" => id}, socket) do
    question = Questions.get_question!(id)
    questions = socket.assigns.questions
    idx = Enum.find_index(questions, &(&1.id == question.id))
    if idx && idx < length(questions) - 1 do
      nxt = Enum.at(questions, idx + 1)
      Questions.reorder_question(question, nxt.position)
      Questions.reorder_question(nxt, question.position)
    end
    {:noreply, assign(socket, questions: Questions.list_questions(socket.assigns.survey.id))}
  end

  @impl true
  def handle_event("drag_reorder", %{"question_id" => qid, "new_index" => new_idx_str}, socket) do
    new_idx = String.to_integer(new_idx_str)
    questions = socket.assigns.questions
    question = Enum.find(questions, &(&1.id == qid))
    if question do
      old_idx = Enum.find_index(questions, &(&1.id == qid))
      if old_idx != new_idx do
        target = Enum.at(questions, new_idx)
        # Swap positions: give dragged item the target position
        Questions.reorder_question(question, target.position)
      end
    end
    {:noreply, assign(socket, questions: Questions.list_questions(socket.assigns.survey.id))}
  end

  @impl true
  def handle_event("toggle_preview", _params, socket) do
    {:noreply, assign(socket, preview_mode: !socket.assigns.preview_mode)}
  end
end
