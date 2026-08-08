// Theme toggle
(function () {
  var html = document.documentElement;
  window.addEventListener("terra:toggle-theme", function () {
    if (html.classList.contains("dark")) {
      html.classList.remove("dark");
      html.classList.add("light");
      localStorage.setItem("terra-theme", "light");
    } else {
      html.classList.add("dark");
      html.classList.remove("light");
      localStorage.setItem("terra-theme", "dark");
    }
  });
  document.addEventListener("click", function (e) {
    if (e.target.closest("#theme-toggle")) {
      window.dispatchEvent(new CustomEvent("terra:toggle-theme"));
    }
  });
})();

// Accent color picker
(function () {
  var stored = localStorage.getItem("terra-accent");
  if (stored) applyAccent(stored);
  document.addEventListener("input", function (e) {
    var picker = e.target.closest("#accent-picker");
    if (!picker) return;
    applyAccent(picker.value);
    localStorage.setItem("terra-accent", picker.value);
  });
  function applyAccent(hex) {
    var root = document.documentElement.style;
    root.setProperty("--accent", hex);
    root.setProperty("--primary", hex);
    root.setProperty("--ring", hex);
  }
})();

// Drag-and-drop reorder
(function () {
  document.addEventListener("dragstart", function (e) {
    var card = e.target.closest("[data-question-id]");
    if (!card) return;
    card.classList.add("opacity-50");
    e.dataTransfer.effectAllowed = "move";
    e.dataTransfer.setData("text/plain", card.dataset.questionId);
  });
  document.addEventListener("dragend", function (e) {
    var card = e.target.closest("[data-question-id]");
    if (card) card.classList.remove("opacity-50");
  });
  document.addEventListener("dragover", function (e) {
    if (e.target.closest("[data-question-id]")) e.preventDefault();
  });
  document.addEventListener("drop", function (e) {
    var card = e.target.closest("[data-question-id]");
    if (!card) return;
    e.preventDefault();
    var questionId = e.dataTransfer.getData("text/plain");
    var targetId = card.dataset.questionId;
    if (!questionId || !targetId || questionId === targetId) return;
    var list = document.getElementById("questions-list");
    if (!list) return;
    var children = [].slice.call(list.querySelectorAll("[data-question-id]"));
    var targetIdx = children.indexOf(card);
    var btn = document.getElementById("drag-reorder-trigger");
    if (!btn) return;
    btn.setAttribute("phx-value-question_id", questionId);
    btn.setAttribute("phx-value-new_index", targetIdx);
    btn.click();
  });
})();
