set shell := ["bash", "-euo", "pipefail", "-c"]

# Créer un brouillon d’article : just brouillon-article <slug> <titre> <description> <tags>
brouillon-article slug titre description tags:
    ./scripts/new-content.sh post "{{slug}}" "{{titre}}" "{{description}}" "{{tags}}"

# Créer un brouillon de page : just brouillon-page <slug> <titre> <description> <tags>
brouillon-page slug titre description tags:
    ./scripts/new-content.sh page "{{slug}}" "{{titre}}" "{{description}}" "{{tags}}"

# Publier après revue humaine ; ajouter --replace pour mettre à jour un contenu existant.
publier type slug option="":
    ./scripts/publish-draft.sh "{{type}}" "{{slug}}" "{{option}}"

# Vérifier le frontmatter et la structure du contenu publié.
verifier-contenu:
    ./scripts/check-content.sh

# Générer les diagrammes Mermaid des brouillons et des contenus publiés.
diagrammes:
    ./scripts/render-diagrams.sh --all

# Générer les diagrammes Mermaid des contenus publiés.
diagrammes-publics:
    ./scripts/render-diagrams.sh --published

# Vérifier le formatage du code Gleam.
formater:
    gleam format --check

# Exécuter les tests Gleam.
tester:
    gleam test
    bash test/publish_draft_test.sh

# Analyser les fichiers suivis et non générés à la recherche de secrets.
securite:
    gitleaks detect --source . --no-git --redact

# Exécuter toutes les validations avant une revue ou une publication.
verifier:
    just securite
    just formater
    just tester
    just verifier-contenu
    just construire

# Générer le site statique dans dist/.
construire:
    ./scripts/render-diagrams.sh --published
    gleam run -m mazama_blog

# Lancer un aperçu local avec rechargement automatique.
apercu:
    gleam run -m mazama_blog/dev
