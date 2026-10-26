(() => {
  const controls = document.querySelector("[data-search-controls]");

  if (!controls) {
    return;
  }

  const input = controls.querySelector("#site-search");
  const status = controls.querySelector("[data-search-status]");
  const resetButton = controls.querySelector("[data-clear-search]");
  const suggestions = controls.querySelector("[data-search-suggestions]");
  const visibleCards = Array.from(document.querySelectorAll(".post-card[data-search]"));
  const cards = visibleCards.length > 0
    ? visibleCards
    : Array.from(document.querySelectorAll("[data-search-source]"));
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

  const hasActiveFilter = () => Boolean(input.value.trim() || selectedTag);

  const setSuggestionsVisible = visible => {
    suggestions.hidden = !visible;
    input.setAttribute("aria-expanded", String(visible));
  };

  const suggestionLinks = () =>
    Array.from(suggestions.querySelectorAll(".search-suggestion"));

  const focusSuggestion = index => {
    suggestionLinks()[index]?.focus();
  };

  const bindSuggestionNavigation = () => {
    suggestionLinks().forEach((suggestion, index) => {
      suggestion.addEventListener("keydown", event => {
        if (event.key === "ArrowDown") {
          event.preventDefault();
          focusSuggestion(index + 1);
        }

        if (event.key === "ArrowUp") {
          event.preventDefault();

          if (index === 0) {
            input.focus();
          } else {
            focusSuggestion(index - 1);
          }
        }

        if (event.key === "Escape") {
          event.preventDefault();
          setSuggestionsVisible(false);
          input.focus();
        }
      });
    });
  };

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

  const renderSuggestions = matches => {
    suggestions.replaceChildren();

    const summary = document.createElement("p");
    const noteLabel = matches.length > 1 ? "notes" : "note";

    summary.className = "search-summary";
    summary.textContent = `${matches.length} ${noteLabel} trouvée${matches.length > 1 ? "s" : ""}`;
    suggestions.append(summary);

    matches.slice(0, 4).forEach(card => {
      const titleLink = card.querySelector("[data-search-title], h3 a");
      const description = card.querySelector("p");
      const suggestion = document.createElement("a");
      const title = document.createElement("strong");
      const summary = document.createElement("span");
      const tags = document.createElement("span");
      const tagList = (card.dataset.tags || "").split(",").filter(Boolean);

      suggestion.className = "search-suggestion";
      suggestion.href = titleLink.href;
      suggestion.setAttribute("role", "option");
      title.textContent = titleLink.textContent;
      summary.textContent = description.textContent;
      tags.className = "search-suggestion-tags";
      tags.textContent = tagList.slice(0, 3).join(" · ");
      suggestion.append(title, summary, tags);
      suggestions.append(suggestion);
    });

    if (matches.length === 0) {
      const empty = document.createElement("p");

      empty.className = "search-empty";
      empty.textContent = "Aucune note ne correspond à cette recherche.";
      suggestions.append(empty);
    }

    bindSuggestionNavigation();
  };

  const filterCards = () => {
    const query = normalize(input.value.trim());
    const matches = [];

    cards.forEach(card => {
      const matchesQuery = !query || normalize(card.dataset.search || "").includes(query);
      const tags = (card.dataset.tags || "").split(",");
      const matchesTag = !selectedTag || tags.includes(selectedTag);
      const visible = matchesQuery && matchesTag;

      if (visibleCards.length > 0) {
        card.hidden = !visible;
      }

      if (visible) {
        matches.push(card);
      }
    });

    const active = hasActiveFilter();
    const filters = [];

    if (input.value.trim()) {
      filters.push(`recherche : « ${input.value.trim()} »`);
    }

    if (selectedTag) {
      filters.push(`tag : ${selectedTag}`);
    }

    status.textContent = `${matches.length} note${matches.length > 1 ? "s" : ""}${filters.length ? ` · ${filters.join(" · ")}` : ""}`;
    resetButton.hidden = !active;
    renderSuggestions(matches);
    setSuggestionsVisible(active);
    updateUrl(input.value.trim());
  };

  input.addEventListener("input", filterCards);

  input.addEventListener("focus", () => {
    setSuggestionsVisible(hasActiveFilter());
  });

  input.addEventListener("keydown", event => {
    if (event.key === "ArrowDown" && hasActiveFilter()) {
      event.preventDefault();
      focusSuggestion(0);
      return;
    }

    if (event.key === "ArrowUp" && hasActiveFilter()) {
      event.preventDefault();
      focusSuggestion(suggestionLinks().length - 1);
      return;
    }

    if (event.key !== "Escape" || !hasActiveFilter()) {
      return;
    }

    event.preventDefault();
    input.value = "";
    selectedTag = "";
    filterCards();
  });

  input.addEventListener("blur", () => {
    window.setTimeout(() => {
      if (!controls.contains(document.activeElement)) {
        setSuggestionsVisible(false);
      }
    }, 120);
  });

  resetButton.addEventListener("click", () => {
    input.value = "";
    selectedTag = "";
    filterCards();
    input.focus();
  });

  document.addEventListener("click", event => {
    const tag = event.target.closest("[data-filter-tag]");

    if (!tag) {
      return;
    }

    event.preventDefault();
    selectedTag = (tag.dataset.filterTag || "").toLowerCase();
    filterCards();
    input.focus();
  });

  filterCards();
})();


(() => {
  const indicator = document.querySelector("[data-reading-progress]");

  if (!indicator) {
    return;
  }

  let frame = null;

  const updateProgress = () => {
    const maximum = document.documentElement.scrollHeight - window.innerHeight;
    const progress = maximum > 0 ? Math.min(window.scrollY / maximum, 1) : 0;

    indicator.style.transform = `scaleX(${progress})`;
    frame = null;
  };

  const requestUpdate = () => {
    if (frame === null) {
      frame = window.requestAnimationFrame(updateProgress);
    }
  };

  document.addEventListener("scroll", requestUpdate, { passive: true });
  window.addEventListener("resize", requestUpdate);
  updateProgress();
})();
