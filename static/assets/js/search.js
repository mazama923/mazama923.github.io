(() => {
  const controls = document.querySelector("[data-search-controls]");

  if (!controls) {
    return;
  }

  const input = controls.querySelector("#site-search");
  const status = controls.querySelector("[data-search-status]");
  const clearTagButton = controls.querySelector("[data-clear-tag]");
  const cards = Array.from(document.querySelectorAll(".post-card[data-search]"));
  const parameters = new URLSearchParams(window.location.search);
  let selectedTag = (parameters.get("tag") || "").trim().toLowerCase();

  input.value = parameters.get("q") || "";

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

  const filterCards = () => {
    const query = normalize(input.value.trim());
    let visibleCount = 0;

    cards.forEach(card => {
      const matchesQuery = !query || normalize(card.dataset.search || "").includes(query);
      const tags = (card.dataset.tags || "").split(",");
      const matchesTag = !selectedTag || tags.includes(selectedTag);
      const visible = matchesQuery && matchesTag;

      card.hidden = !visible;

      if (visible) {
        visibleCount += 1;
      }
    });

    const parts = [`${visibleCount} note${visibleCount > 1 ? "s" : ""}`];

    if (selectedTag) {
      parts.push(`tag : ${selectedTag}`);
    }

    if (query) {
      parts.push(`recherche : « ${input.value.trim()} »`);
    }

    status.textContent = parts.join(" · ");
    clearTagButton.hidden = !selectedTag;
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
