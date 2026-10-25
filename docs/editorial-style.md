# Style éditorial

## Langue et ton

Rédigez en français naturel pour des praticiens. Préférez des explications directes, des commandes concrètes, des versions, des contraintes et des modes de défaillance aux affirmations générales. Expliquez pourquoi un choix a été fait lorsque ce contexte a un impact opérationnel.

Le code, les identifiants, les clés de configuration, les chemins, les commandes et les noms d’API restent dans leur forme technique d’origine. Ne traduisez pas les placeholders techniques `__TITLE__`, `__DATE__`, `__DESCRIPTION__`, `__TAGS__` et `__SLUG__` des modèles ; traduisez les valeurs qui les remplacent.

## Structure

- Commencez par le problème et le résultat attendu.
- Indiquez les hypothèses et prérequis avant les commandes.
- Utilisez des sections courtes avec des titres descriptifs en français.
- Gardez des commandes minimales, copiables et idempotentes lorsque possible.
- Terminez par des indications de validation ou de retour arrière lorsqu’une modification affecte des systèmes de production.

## Conventions techniques

- Utilisez l’anglais pour le code, les identifiants, les clés de configuration, les chemins et les commandes.
- Épinglez ou indiquez les versions lorsque le comportement en dépend.
- Citez les variables shell et utilisez `set -euo pipefail` dans les exemples Bash, sauf raison contraire.
- Indiquez les implications de sécurité pour les credentials, l’exposition réseau et les opérations destructrices.
- Remplacez les valeurs sensibles par des placeholders français explicites, par exemple `[TOKEN_REDACTED]`, `example.invalid` ou `host.example.invalid`.

## Règles de confidentialité

Avant toute rédaction ou relecture, appliquez la checklist de [`securite-ia.md`](securite-ia.md). Aucun exemple ne doit révéler de token, clé, mot de passe, nom de domaine interne, IPv4/IPv6 interne, hostname interne ni capture contenant des données identifiantes.

Les extraits provenant de journaux, terminaux ou consoles d’administration sont redigés avant leur insertion. Une capture est refusée si les valeurs sensibles ne peuvent pas être masquées de manière fiable.

## Métadonnées

Le titre est précis et concis. La description est un résumé factuel autonome, adapté à un flux ou un résultat de recherche. Les tags identifient les technologies ou thèmes opérationnels selon la convention CSV en minuscules du dépôt.
