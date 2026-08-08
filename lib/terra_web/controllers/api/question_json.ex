defmodule TerraWeb.Api.QuestionJSON do
  def show(%{question: question}) do
    %{question: question_json(question)}
  end

  def question_json(question) do
    opts = Ecto.assoc_loaded?(question.options) && question.options || []
    %{
      id: question.id,
      survey_id: question.survey_id,
      type: question.type,
      title: question.title,
      position: question.position,
      required: question.required,
      options: Enum.map(opts, fn o ->
        %{id: o.id, question_id: o.question_id, label: o.label, position: o.position, next_question_id: o.next_question_id}
      end)
    }
  end
end
