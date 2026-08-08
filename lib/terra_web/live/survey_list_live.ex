defmodule TerraWeb.SurveyListLive do
  use TerraWeb, :live_view

  alias Terra.Surveys

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, surveys: load_surveys(socket))}
  end

  @impl true
  def handle_params(_params, _url, socket) do
    {:noreply, socket}
  end

  @impl true
  def handle_event("create_survey", %{"title" => title}, socket) do
    user = socket.assigns[:current_user]
    if user do
      case Surveys.create_survey(%{title: title, user_id: user.id}) do
        {:ok, _survey} ->
          {:noreply, assign(socket, surveys: load_surveys(socket))}
        {:error, _changeset} ->
          {:noreply, socket}
      end
    else
      {:noreply, put_flash(socket, :error, "You must log in to create surveys.")}
    end
  end

  @impl true
  def handle_event("delete_survey", %{"id" => id}, socket) do
    user = socket.assigns[:current_user]
    if user do
      survey = Surveys.get_user_survey!(user.id, id)
      {:ok, _} = Surveys.delete_survey(survey)
      {:noreply, assign(socket, surveys: load_surveys(socket))}
    else
      {:noreply, put_flash(socket, :error, "You must log in to delete surveys.")}
    end
  end

  @impl true
  def handle_event("toggle_publish", %{"id" => id}, socket) do
    user = socket.assigns[:current_user]
    if user do
      survey = Surveys.get_user_survey!(user.id, id)
      {:ok, _} = Surveys.publish_survey(survey)
      {:noreply, assign(socket, surveys: load_surveys(socket))}
    else
      {:noreply, put_flash(socket, :error, "You must log in to manage surveys.")}
    end
  end

  defp load_surveys(socket) do
    if socket.assigns[:current_user] do
      Surveys.list_user_surveys(socket.assigns.current_user.id)
    else
      Surveys.list_surveys()
    end
  end
end
