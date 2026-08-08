# USAGE

## Starting the Application

After installation, start the server:

```bash
mix phx.server
```

Open [http://localhost:4000](http://localhost:4000) in your browser.

## Web Interface

### Authentication
- Click **Sign up** to create a new user account (email + password).
- Log in with existing credentials.
- User authentication logic lives in `lib/terra_web/user_auth.ex` and `lib/terra_web/live/user_login_live.ex`.

### Survey List (`SurveyListLive`)
- The home page after login shows a list of your surveys (loaded from `lib/terra/surveys.ex`).
- Create a new survey with the **New Survey** button.
- Click a survey title to edit it, or use the controls to delete it.

### Building a Survey (`SurveyBuilderLive`)
- Add questions: click **Add Question**, choose type (text, multiple‑choice, etc.).
- Add options for multiple‑choice questions.
- Define **logic branching**: for each option you can specify a follow‑up question to jump to (conditional paths).
- The builder is implemented in `lib/terra_web/live/survey_builder_live.ex`.

### Taking a Survey (`SurveyTakeLive`)
- Share the survey URL (e.g., `/surveys/:id/take`).
- Respondents answer questions one by one, following the branching logic.
- The flow is handled by `lib/terra_web/live/survey_take_live.ex`.

### Viewing Results (`SurveyResultsLive`)
- After responses are collected, click **Results** on a survey to see aggregated data.
- Charts and statistics for each question (driven by `lib/terra_web/live/survey_results_live.ex`).

### Dark Mode
- A theme toggle (sun/moon icon) is available in the navigation bar.
- Tailwind’s `class` strategy is used; the toggle adds/removes the `dark` class on `<html>`.

## JSON API

The application exposes RESTful API endpoints under `/api` for programmatic access. Controllers are located in `lib/terra_web/controllers/api/`.

### Surveys
- **List surveys**  
  ```bash
  curl http://localhost:4000/api/surveys
  ```
- **Create a survey**  
  ```bash
  curl -X POST http://localhost:4000/api/surveys \
    -H "Content-Type: application/json" \
    -d '{"survey": {"title": "Customer Satisfaction"}}'
  ```
- **Get a survey**  
  ```bash
  curl http://localhost:4000/api/surveys/1
  ```

### Questions
- **List questions for a survey**  
  ```bash
  curl http://localhost:4000/api/surveys/1/questions
  ```
- **Create a question**  
  ```bash
  curl -X POST http://localhost:4000/api/surveys/1/questions \
    -H "Content-Type: application/json" \
    -d '{"question": {"text": "How satisfied are you?", "type": "multiple_choice"}}'
  ```

### Responses
- **Submit a response**  
  ```bash
  curl -X POST http://localhost:4000/api/surveys/1/responses \
    -H "Content-Type: application/json" \
    -d '{"response": {"question_id": 1, "value": "Very satisfied"}}'
  ```
- **List responses for a survey**  
  ```bash
  curl http://localhost:4000/api/surveys/1/responses
  ```

All API endpoints return JSON. Authentication may be required for write operations (check the router and user_auth for token support).

## Seeded Demo Data

After running `mix setup`, the database contains example surveys (with questions, options, branching logic), dummy responses, and a test user (credentials are printed in the seed output or stored in `priv/repo/seeds.exs`). Use these to explore the features immediately.

## Additional Information

- All LiveViews are under `lib/terra_web/live/` with corresponding `.heex` templates.
- Database migrations are in `priv/repo/migrations/`.
- Schema modules (`Survey`, `Question`, `Option`, `Response`, `User`) are in `lib/terra/`.