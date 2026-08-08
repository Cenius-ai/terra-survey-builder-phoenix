defmodule Terra.Responses do
  import Ecto.Query, warn: false
  alias Terra.Repo
  alias Terra.Response

  def list_responses(survey_id) do
    Response
    |> where([r], r.survey_id == ^survey_id)
    |> order_by(desc: :inserted_at)
    |> Repo.all()
  end

  def get_response!(id) do
    Repo.get!(Response, id)
  end

  def submit_response(survey_id, answers) do
    %Response{}
    |> Response.changeset(%{survey_id: survey_id, answers: answers})
    |> Repo.insert()
  end

  def count_responses(survey_id) do
    Response
    |> where([r], r.survey_id == ^survey_id)
    |> Repo.aggregate(:count)
  end
end
