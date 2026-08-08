defmodule TerraWeb.Router do
  use TerraWeb, :router
  import Phoenix.LiveView.Router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {TerraWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug TerraWeb.UserAuth, :fetch_current_user
  end

  pipeline :api do
    plug :accepts, ["json"]
    plug :fetch_session
    plug TerraWeb.UserAuth, :fetch_current_user
  end

  pipeline :api_auth do
    plug TerraWeb.UserAuth, :require_api_authenticated_user
  end

  # ── Session controller actions ────────────────────────────────
  scope "/", TerraWeb do
    pipe_through :browser

    post "/login", UserSessionController, :create
    get "/logout", UserSessionController, :delete
  end

  # ── Public LiveView routes ────────────────────────────────────
  live_session :default, on_mount: [{TerraWeb.UserAuth, :fetch_current_user}] do
    scope "/", TerraWeb do
      pipe_through :browser

      live "/", SurveyListLive, :index
      live "/login", UserLoginLive, :new
    end

    scope "/s", TerraWeb do
      pipe_through :browser

      live "/:slug", SurveyTakeLive, :take
    end
  end

  # ── Protected LiveView routes (auth required) ─────────────────
  live_session :require_auth, on_mount: [{TerraWeb.UserAuth, :require_authenticated_user}] do
    scope "/", TerraWeb do
      pipe_through :browser

      live "/builder/:id", SurveyBuilderLive, :edit
      live "/surveys/:id/results", SurveyResultsLive, :show
    end
  end

  # ── Public API routes (no auth required) ──────────────────────
  scope "/api", TerraWeb.Api do
    pipe_through :api

    get "/s/:slug", ResponseController, :show
    post "/s/:slug/responses", ResponseController, :create
  end

  # ── Protected API routes (auth required) ──────────────────────
  scope "/api", TerraWeb.Api do
    pipe_through [:api, :api_auth]

    get "/surveys", SurveyController, :index
    post "/surveys", SurveyController, :create
    get "/surveys/:id", SurveyController, :show
    put "/surveys/:id", SurveyController, :update
    delete "/surveys/:id", SurveyController, :delete
    post "/surveys/:id/publish", SurveyController, :publish

    get "/surveys/:id/questions", SurveyController, :questions
    post "/surveys/:survey_id/questions", QuestionController, :create

    put "/questions/:id", QuestionController, :update
    delete "/questions/:id", QuestionController, :delete
    put "/questions/:id/reorder", QuestionController, :reorder

    post "/questions/:question_id/options", QuestionController, :create_option
    put "/options/:id", QuestionController, :update_option
    delete "/options/:id", QuestionController, :delete_option

    get "/surveys/:id/results", SurveyController, :results
  end
end
