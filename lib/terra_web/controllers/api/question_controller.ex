defmodule TerraWeb.Api.QuestionController do
  use TerraWeb, :controller

  alias Terra.{Surveys, Questions}

  def create(conn, %{"survey_id" => survey_id} = params) do
    user = conn.assigns.current_user
    # Verify survey ownership
    _survey = Surveys.get_user_survey!(user.id, survey_id)

    attrs = %{}
    attrs = Map.put(attrs, "title", params["title"])
    attrs = if Map.has_key?(params, "type"), do: Map.put(attrs, "type", params["type"]), else: attrs
    attrs = if Map.has_key?(params, "required"), do: Map.put(attrs, "required", params["required"]), else: attrs

    case Questions.create_question(survey_id, attrs) do
      {:ok, question} ->
        question = Questions.get_question!(question.id)
        conn |> put_status(:created) |> render("show.json", question: question)
      {:error, changeset} ->
        conn |> put_status(:unprocessable_entity) |> json(%{errors: format_errors(changeset)})
    end
  end

  def update(conn, %{"id" => id} = params) do
    user = conn.assigns.current_user
    question = Questions.get_user_question!(user.id, id)
    attrs = Map.take(params, ["title", "type", "required"])

    case Questions.update_question(question, attrs) do
      {:ok, question} ->
        question = Questions.get_question!(question.id)
        render(conn, "show.json", question: question)
      {:error, changeset} ->
        conn |> put_status(:unprocessable_entity) |> json(%{errors: format_errors(changeset)})
    end
  end

  def delete(conn, %{"id" => id}) do
    user = conn.assigns.current_user
    question = Questions.get_user_question!(user.id, id)
    {:ok, _} = Questions.delete_question(question)
    send_resp(conn, :no_content, "")
  end

  def reorder(conn, %{"id" => id, "position" => position}) do
    user = conn.assigns.current_user
    question = Questions.get_user_question!(user.id, id)
    pos = String.to_integer(position)

    case Questions.reorder_question(question, pos) do
      {:ok, question} ->
        render(conn, "show.json", question: question)
      {:error, changeset} ->
        conn |> put_status(:unprocessable_entity) |> json(%{errors: format_errors(changeset)})
    end
  end

  def create_option(conn, %{"question_id" => question_id} = params) do
    user = conn.assigns.current_user
    # Verify ownership through question → survey chain
    _question = Questions.get_user_question!(user.id, question_id)

    attrs = %{"label" => params["label"]}
    attrs = if Map.has_key?(params, "next_question_id"), do: Map.put(attrs, "next_question_id", params["next_question_id"]), else: attrs

    case Questions.create_option(question_id, attrs) do
      {:ok, option} ->
        conn |> put_status(:created) |> json(option_json(option))
      {:error, changeset} ->
        conn |> put_status(:unprocessable_entity) |> json(%{errors: format_errors(changeset)})
    end
  end

  def update_option(conn, %{"id" => id} = params) do
    user = conn.assigns.current_user
    option = Questions.get_user_option!(user.id, id)
    attrs = Map.take(params, ["label", "next_question_id"])

    case Questions.update_option(option, attrs) do
      {:ok, option} ->
        json(conn, option_json(option))
      {:error, changeset} ->
        conn |> put_status(:unprocessable_entity) |> json(%{errors: format_errors(changeset)})
    end
  end

  def delete_option(conn, %{"id" => id}) do
    user = conn.assigns.current_user
    option = Questions.get_user_option!(user.id, id)
    {:ok, _} = Questions.delete_option(option)
    send_resp(conn, :no_content, "")
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

  defp format_errors(changeset) do
    Ecto.Changeset.traverse_errors(changeset, fn {msg, opts} ->
      Enum.reduce(opts, msg, fn {key, value}, acc ->
        String.replace(acc, "%{#{key}}", to_string(value))
      end)
    end)
  end
end
