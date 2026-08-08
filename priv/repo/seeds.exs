alias Terra.{Repo, Survey, Question, Option, Response, User}
alias Terra.Accounts

# Helper: insert only if not exists
idempotent_insert = fn schema, finder, attrs ->
  case Repo.get_by(schema, finder) do
    nil ->
      struct = struct(schema, attrs)
      Repo.insert!(struct)
    existing ->
      existing
  end
end

# ── Demo user ──
demo_user =
  case Accounts.get_user_by_email("cenius@cenius.ai") do
    nil ->
      {:ok, user} = Accounts.create_user(%{email: "cenius@cenius.ai", password: "cenius"})
      IO.puts("Created demo user: cenius@cenius.ai / cenius")
      user
    existing ->
      IO.puts("Demo user already exists: cenius@cenius.ai")
      existing
  end

# ── Survey 1: Customer Satisfaction ──
s1 = idempotent_insert.(Survey, [slug: "customer-satisfaction"], %{
  title: "Customer Satisfaction Survey",
  slug: "customer-satisfaction",
  published: true,
  theme: %{"accent" => "#db3e98"}
})

_q1_1 = idempotent_insert.(Question, [survey_id: s1.id, position: 0], %{
  survey_id: s1.id, type: "text", title: "What's your name?", position: 0, required: false
})

q1_2 = idempotent_insert.(Question, [survey_id: s1.id, position: 1], %{
  survey_id: s1.id, type: "multiple_choice", title: "How did you hear about us?", position: 1, required: true
})

_q1_3 = idempotent_insert.(Question, [survey_id: s1.id, position: 2], %{
  survey_id: s1.id, type: "rating", title: "How would you rate our product?", position: 2, required: true
})

_q1_4 = idempotent_insert.(Question, [survey_id: s1.id, position: 3], %{
  survey_id: s1.id, type: "text", title: "What could we improve?", position: 3, required: false
})

q1_5 = idempotent_insert.(Question, [survey_id: s1.id, position: 4], %{
  survey_id: s1.id, type: "multiple_choice", title: "Would you recommend us?", position: 4, required: true
})

# Options for q1_2 (How did you hear about us?)
for {label, pos} <- Enum.with_index(["Social media", "Friend referral", "Search engine", "Advertisement", "Other"]) do
  idempotent_insert.(Option, [question_id: q1_2.id, position: pos], %{
    question_id: q1_2.id, label: label, position: pos, next_question_id: nil
  })
end

# Options for q1_5 (Would you recommend us?)
for {label, pos} <- Enum.with_index(["Definitely yes", "Probably yes", "Not sure", "Probably not"]) do
  idempotent_insert.(Option, [question_id: q1_5.id, position: pos], %{
    question_id: q1_5.id, label: label, position: pos, next_question_id: nil
  })
end

# Submit some responses for survey 1
response_data_s1 = [
  %{"0" => "Alice Chen", "1" => "Social media", "2" => "5", "3" => "Nothing, love it!", "4" => "Definitely yes"},
  %{"0" => "Bob Martinez", "1" => "Friend referral", "2" => "4", "3" => "Better onboarding docs", "4" => "Probably yes"},
  %{"0" => "Carol Nguyen", "1" => "Search engine", "2" => "5", "3" => "More integrations please", "4" => "Definitely yes"},
  %{"0" => "David Park", "1" => "Advertisement", "2" => "3", "3" => "UI could be cleaner", "4" => "Not sure"},
  %{"0" => "Elena Rossi", "1" => "Social media", "2" => "5", "3" => "Perfect as-is", "4" => "Definitely yes"},
  %{"0" => "Frank Okafor", "1" => "Search engine", "2" => "4", "3" => "Mobile app would be nice", "4" => "Probably yes"},
  %{"0" => "Grace Kim", "1" => "Friend referral", "2" => "5", "3" => "Keep up the great work", "4" => "Definitely yes"},
  %{"0" => "Hassan Ali", "1" => "Other", "2" => "2", "3" => "Customer support is slow", "4" => "Probably not"},
]

for answers <- response_data_s1 do
  exists = Repo.get_by(Response, survey_id: s1.id, answers: answers)
  if is_nil(exists) do
    Repo.insert!(%Response{survey_id: s1.id, answers: answers})
  end
end

# ── Survey 2: Product Feedback (with branching) ──
s2 = idempotent_insert.(Survey, [slug: "product-feedback"], %{
  title: "Product Feedback Form",
  slug: "product-feedback",
  published: true,
  theme: %{"accent" => "#db3e98"}
})

_q2_1 = idempotent_insert.(Question, [survey_id: s2.id, position: 0], %{
  survey_id: s2.id, type: "text", title: "Your email (optional)", position: 0, required: false
})

q2_2 = idempotent_insert.(Question, [survey_id: s2.id, position: 1], %{
  survey_id: s2.id, type: "multiple_choice", title: "Which feature do you use most?", position: 1, required: true
})

q2_3a = idempotent_insert.(Question, [survey_id: s2.id, position: 2], %{
  survey_id: s2.id, type: "rating", title: "How satisfied are you with the dashboard?", position: 2, required: true
})

q2_3b = idempotent_insert.(Question, [survey_id: s2.id, position: 3], %{
  survey_id: s2.id, type: "rating", title: "How satisfied are you with reporting?", position: 3, required: true
})

q2_4 = idempotent_insert.(Question, [survey_id: s2.id, position: 4], %{
  survey_id: s2.id, type: "text", title: "Any additional feedback?", position: 4, required: false
})

# Options for q2_2 with branching
_o2_2a = idempotent_insert.(Option, [question_id: q2_2.id, position: 0], %{
  question_id: q2_2.id, label: "Dashboard", position: 0, next_question_id: q2_3a.id
})
_o2_2b = idempotent_insert.(Option, [question_id: q2_2.id, position: 1], %{
  question_id: q2_2.id, label: "Reporting", position: 1, next_question_id: q2_3b.id
})
_o2_2c = idempotent_insert.(Option, [question_id: q2_2.id, position: 2], %{
  question_id: q2_2.id, label: "Both equally", position: 2, next_question_id: q2_4.id
})

# Responses for survey 2
response_data_s2 = [
  %{"0" => "jane@example.com", "1" => "Dashboard", "2" => "4", "4" => "Love the widgets"},
  %{"0" => "mark@example.com", "1" => "Reporting", "3" => "5", "4" => "Export to CSV would help"},
  %{"0" => "lisa@example.com", "1" => "Both equally", "4" => "Great overall experience"},
  %{"0" => "tom@example.com", "1" => "Dashboard", "2" => "3", "4" => "Loading times could improve"},
  %{"0" => "priya@example.com", "1" => "Reporting", "3" => "4", "4" => "Charts are beautiful"},
]

for answers <- response_data_s2 do
  exists = Repo.get_by(Response, survey_id: s2.id, answers: answers)
  if is_nil(exists) do
    Repo.insert!(%Response{survey_id: s2.id, answers: answers})
  end
end

# ── Survey 3: Draft — Event Registration (not published) ──
s3 = idempotent_insert.(Survey, [slug: "event-registration"], %{
  title: "Annual Summit Registration",
  slug: "event-registration",
  published: false,
  theme: %{"accent" => "#db3e98"}
})

_q3_1 = idempotent_insert.(Question, [survey_id: s3.id, position: 0], %{
  survey_id: s3.id, type: "text", title: "Full name", position: 0, required: true
})

q3_2 = idempotent_insert.(Question, [survey_id: s3.id, position: 1], %{
  survey_id: s3.id, type: "multiple_choice", title: "Dietary preference", position: 1, required: true
})

q3_3 = idempotent_insert.(Question, [survey_id: s3.id, position: 2], %{
  survey_id: s3.id, type: "multiple_choice", title: "Which workshops interest you?", position: 2, required: false
})

for {label, pos} <- Enum.with_index(["Vegetarian", "Vegan", "Gluten-free", "No restrictions"]) do
  idempotent_insert.(Option, [question_id: q3_2.id, position: pos], %{
    question_id: q3_2.id, label: label, position: pos, next_question_id: nil
  })
end

for {label, pos} <- Enum.with_index(["AI & ML", "Cloud Architecture", "Developer Experience", "Security"]) do
  idempotent_insert.(Option, [question_id: q3_3.id, position: pos], %{
    question_id: q3_3.id, label: label, position: pos, next_question_id: nil
  })
end

IO.puts("Seeds completed: #{Repo.aggregate(Survey, :count)} total surveys, #{Repo.aggregate(Response, :count)} total responses")
