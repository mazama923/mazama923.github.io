# Politique de sécurité

## Signalement responsable

Ne publiez pas de vulnérabilité ni de secret dans une issue publique, une pull request, un commentaire ou une discussion. Contactez le mainteneur du dépôt par un canal privé convenu et fournissez un résumé minimal : composant concerné, impact, conditions de reproduction et mesures de confinement déjà prises.

Ne joignez jamais la valeur d’un secret au signalement. Remplacez-la par `[SECRET_REDACTED]` et limitez les journaux ou captures aux extraits indispensables, après expurgation.

## Contenu et confidentialité

Le dépôt doit rester publiable sans révéler d’informations d’infrastructure ou de données personnelles. Avant toute contribution, appliquez la checklist de [`docs/securite-ia.md`](docs/securite-ia.md), notamment pour :

- tokens, clés API, clés privées, certificats, mots de passe, cookies et credentials ;
- noms de domaine internes, URL d’administration et noms d’organisation non publics ;
- IPv4 et IPv6 internes, hostnames, identifiants de comptes et chemins personnels ;
- captures d’écran, journaux, sorties de commandes et exports de consoles.

## Usage des LLM cloud

Aucune donnée non publique ne doit être envoyée à un LLM cloud par défaut. Tout envoi exige une demande explicite de l’utilisateur, une expurgation vérifiée, le minimum de données nécessaire et l’acceptation de la politique du fournisseur concernant la rétention et l’entraînement.

Les agents ne lisent ni ne divulguent `.env`, clés, credentials, configurations cloud ou fichiers personnels sans demande explicite et nécessité établie. Ils n’effectuent aucun appel réseau, déploiement ou publication sans demande explicite.

## Réponse à un secret exposé

1. Contenez l’exposition et évitez toute nouvelle diffusion de la valeur.
2. Révoquez ou faites tourner le secret immédiatement ; supprimer un fichier ou réécrire Git ne le rend pas invalide.
3. Évaluez les branches, tags, artefacts CI, caches, déploiements, journaux et services tiers potentiellement affectés.
4. Retirez le secret du contenu et de l’historique avec une procédure approuvée, après sa rotation.
5. Vérifiez les traces restantes et documentez les actions sans inclure le secret.

La procédure détaillée, y compris le traitement d’une fuite vers un LLM cloud, figure dans [`docs/securite-ia.md`](docs/securite-ia.md).

## Périmètre

Cette politique couvre le contenu, les scripts et la configuration du dépôt. Elle ne remplace pas les obligations de sécurité propres aux fournisseurs, plateformes ou systèmes mentionnés dans les articles.
