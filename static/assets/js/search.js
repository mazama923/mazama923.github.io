(() => {
  const controls = document.querySelector("[data-search-controls]");

  if (!controls) {
    return;
  }

  const input = controls.querySelector("#site-search");
  const feedback = controls.querySelector(".search-feedback");
  const status = controls.querySelector("[data-search-status]");
  const clearTagButton = controls.querySelector("[data-clear-tag]");
  const suggestions = controls.querySelector("[data-search-suggestions]");
  const cards = Array.from(
    document.querySelectorAll("[data-search-index] .post-card[data-search]"),
  );
  const parameters = new URLSearchParams(window.location.search);
  let selectedTag = (parameters.get("tag") || "").trim().toLowerCase();

  input.value = parameters.get("q") || "";

  if (cards.length === 0) {
    return;
  }

  const normalize = value =>
    value
      .normalize("NFD")
      .replace(/[\u0300-\u036f]/g, "")
      .toLowerCase();

  const updateUrl = query => {
    const url = new URL(window.location.href);

    if (query) {
      url.searchParams.set("q", query);
    } else {
      url.searchParams.delete("q");
    }

    if (selectedTag) {
      url.searchParams.set("tag", selectedTag);
    } else {
      url.searchParams.delete("tag");
    }

    window.history.replaceState(null, "", url);
  };

  const renderSuggestions = (matches, query) => {
    suggestions.replaceChildren();
    suggestions.hidden = !query;

    matches.slice(0, 5).forEach(card => {
      const titleLink = card.querySelector("h3 a");
      const description = card.querySelector("p");
      const suggestion = document.createElement("a");
      const title = document.createElement("strong");
      const summary = document.createElement("span");

      suggestion.className = "search-suggestion";
      suggestion.href = titleLink.href;
      title.textContent = titleLink.textContent;
      summary.textContent = description.textContent;
      suggestion.append(title, summary);
      suggestions.append(suggestion);
    });

    if (matches.length === 0) {
      const empty = document.createElement("p");

      empty.className = "search-empty";
      empty.textContent = "Aucune note ne correspond à cette recherche.";
      suggestions.append(empty);
    }
  };

  const filterCards = () => {
    const query = normalize(input.value.trim());
    const matches = [];

    cards.forEach(card => {
      const matchesQuery = !query || normalize(card.dataset.search || "").includes(query);
      const tags = (card.dataset.tags || "").split(",");
      const matchesTag = !selectedTag || tags.includes(selectedTag);
      const visible = matchesQuery && matchesTag;

      card.hidden = !visible;

      if (visible) {
        matches.push(card);
      }
    });

    const parts = [`${matches.length} note${matches.length > 1 ? "s" : ""}`];

    if (selectedTag) {
      parts.push(`tag : ${selectedTag}`);
    }

    if (query) {
      parts.push(`recherche : « ${input.value.trim()} »`);
    }

    status.textContent = parts.join(" · ");
    feedback.hidden = !query && !selectedTag;
    clearTagButton.hidden = !selectedTag;
    renderSuggestions(matches, query);
    updateUrl(input.value.trim());
  };

  input.addEventListener("input", filterCards);

  clearTagButton.addEventListener("click", () => {
    selectedTag = "";
    filterCards();
  });

  document.addEventListener("click", event => {
    const tag = event.target.closest("[data-filter-tag]");

    if (!tag) {
      return;
    }

    event.preventDefault();
    selectedTag = tag.dataset.filterTag || "";
    filterCards();
    input.focus();
  });

  filterCards();
})();
