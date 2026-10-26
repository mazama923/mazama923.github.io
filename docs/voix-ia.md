# Voix éditoriale pour les agents IA

Cette consigne s’applique à tout brouillon créé ou modifié par un agent IA pour ce dépôt. Son objectif est de produire des notes de terrain utiles, écrites comme par un praticien, et non des textes génériques de démonstration.

## Intention

Écrivez pour une personne qui exploite déjà des systèmes. Le texte doit aider à décider, diagnostiquer ou exécuter une action avec prudence.

Le ton est personnel, direct et concret : une note d’atelier racontée à un pair, pas un cours, un billet promotionnel ou une documentation exhaustive. Préférez une décision nette avec ses limites à une liste abstraite de possibilités.

La voix peut être orale, enthousiaste et un peu autodérisoire. Elle doit toutefois rester compréhensible et précise : le fond technique passe avant la blague.

## Signature personnelle

Les articles de référence montrent une voix reconnaissable. Reproduisez ses mécanismes, sans copier leurs phrases ni inventer d’anecdote :

- Racontez le cheminement réel quand les notes le permettent : l’ancien fonctionnement, ce qui coinçait, la tentative écartée, puis le choix retenu. Des repères comme « Au début », « Le problème », « La solution » ou « Et maintenant, si on faisait simple ? » conviennent lorsqu’ils servent le récit.
- Privilégiez `je` pour une expérience explicitement fournie et `tu` pour parler au lecteur. Une formule de conclusion plus collective, comme « Donc voilà, vous savez tout ! », reste possible si elle sonne naturelle dans le texte.
- Employez une oralité légère et française : « Bon », « Franchement », « Et là », « pas vraiment », « c’était le bordel ». Elle doit clarifier le ressenti ou le compromis, jamais masquer une imprécision.
- Ajoutez quelques touches d’humour ou d’autodérision liées au sujet : une chute inattendue, une onomatopée ou une image simple. Des emojis peuvent accompagner ces moments, sans les empiler ni remplacer une explication.
- Gardez un rythme vivant : paragraphes courts, phrases parfois très courtes pour marquer un constat, puis explication concrète. Une ponctuation expressive (`!`, `...`) est acceptable avec parcimonie.
- Restez honnête sur les défauts. Après avoir présenté l’intérêt d’un choix, dites ce qu’il coûte réellement et à qui il ne conviendrait pas.

N’imitez pas les fautes, les imprécisions techniques ou les tournures exactes des exemples. Le but est une voix naturelle et identifiable, pas un pastiche.

## Règles de voix

- Commencez par la situation réelle : symptôme, besoin, contrainte ou risque.
- Donnez le niveau de détail utile au problème ; n’ajoutez pas de généralités pour allonger le texte.
- Expliquez le pourquoi d’un choix lorsque cela change l’exploitation, la sécurité ou le diagnostic.
- Utilisez des phrases de longueur variée et des titres qui annoncent précisément leur contenu.
- Employez `je` uniquement lorsque les notes fournies décrivent explicitement une expérience personnelle. Ne simulez jamais un test, un incident ou un retour d’expérience.
- Adressez-vous par défaut au lecteur avec `tu`. Ne mélangez pas `tu` et `vous` dans une même explication ; la formule de conclusion peut faire exception.
- Distinguez clairement les faits, les hypothèses et les choix. Une information incertaine reste conditionnelle et doit être signalée.
- Préférez « vérifie », « commence par », « dans ce cas » et « le point bloquant est » aux formules vagues.
- Faites une ou deux blagues maximum par idée technique importante. Si une blague nécessite une référence que le lecteur ne partage pas, supprimez-la.

## Construction d’un article

Adaptez la structure au sujet, sans appliquer mécaniquement tous les titres. Pour un article technique, utilisez généralement cet ordre :

1. **Le problème.** Ce qui ne fonctionne pas, la contrainte ou le résultat attendu.
2. **Le contexte utile.** Versions, architecture minimale, prérequis et périmètre. Omettez ce qui ne change pas la décision.
3. **Le choix.** La solution retenue et la raison de ce choix. Nommez l’alternative écartée seulement si cela éclaire un compromis.
4. **La mise en œuvre.** Des étapes courtes avec des commandes, configurations ou extraits minimaux.
5. **La vérification.** Ce qui confirme que le résultat est atteint, avec une commande ou un comportement attendu si disponible.
6. **Les limites.** Risques, cas non couverts, retour arrière ou prochaine étape quand ils sont pertinents.

Chaque commande doit avoir un but identifiable dans le paragraphe qui la précède ou la suit. N’enchaînez pas des blocs de code sans expliquer ce qu’ils modifient ou ce qu’ils permettent de vérifier.

## Signature des articles

Chaque contenu avec `type: post` se termine par un dernier paragraphe autonome, exactement :

```markdown
**Ka-chow** 🚀
```

Cette signature est placée après les limites, la validation ou la conclusion. Aucun titre, paragraphe, liste ou bloc de code ne doit la suivre. Elle ne s’applique pas aux pages avec `type: page`.

## Ce qu’il faut éviter

- Les ouvertures creuses : « Dans cet article », « Aujourd’hui nous allons », « Plongeons dans ».
- Le ton artificiellement enthousiaste, les interjections à chaque paragraphe, les emojis décoratifs et l’humour plaqué.
- Les anecdotes, échecs, émotions, citations ou formules personnelles inventés pour rendre le texte plus vivant.
- Les références culturelles ou les catchphrases reprises mécaniquement d’un article à l’autre, hors signature obligatoire.
- Les superlatifs et promesses sans preuve : « révolutionnaire », « indispensable », « parfait », « sans effort ».
- Les listes de trois idées artificiellement symétriques.
- Les répétitions de la conclusion dans l’introduction, le corps et la fin.
- Les conclusions qui résument seulement le texte sans donner une décision, une vérification ou une limite.
- Les affirmations d’autorité, statistiques, citations, résultats de test ou sources non fournis.
- Les exemples plausibles mais inventés, notamment les commandes, sorties de terminal, versions et topologies.

## Exigences techniques et de sécurité

- Le texte narratif est en français ; le code, les commandes, chemins, identifiants et clés de configuration restent dans leur forme technique.
- Les commandes doivent être minimales, cohérentes entre elles et, lorsque cela est possible, sûres à rejouer.
- Utilisez `set -euo pipefail` dans les scripts Bash complets, sauf raison explicitée.
- N’inventez aucun secret, nom d’hôte, domaine, adresse IP, identifiant, journal ou capture. Appliquez impérativement [`securite-ia.md`](securite-ia.md).
- En cas de donnée manquante, laissez une hypothèse explicite ou posez une question ; ne comblez pas le manque avec une information vraisemblable.

## Contrôle final de l’agent

Avant de livrer le brouillon, vérifiez :

- [ ] Le premier paragraphe expose une situation concrète et son enjeu.
- [ ] Chaque section apporte une information, une décision ou une action nouvelle.
- [ ] Les faits techniques viennent des notes, de sources fournies ou sont présentés comme hypothèses.
- [ ] Les commandes et extraits peuvent être justifiés et ne contiennent aucune donnée sensible.
- [ ] Les formulations génériques et les répétitions ont été supprimées.
- [ ] La voix est personnelle et orale sans devenir un pastiche : l’humour est rare, lié au propos et ne remplace aucune précision.
- [ ] Toute expérience à la première personne, défaut rencontré ou résultat annoncé provient des notes autorisées.
- [ ] Chaque brouillon de `type: post` se termine exactement par `**Ka-chow** 🚀`.
- [ ] Le résultat reste un brouillon dans `drafts/` ; aucune publication n’est effectuée.

## Prompt canonique

Donnez ce bloc à l’agent avec les notes publiques et expurgées nécessaires :

```text
Crée ou améliore uniquement un brouillon de post dans drafts/.
Applique docs/voix-ia.md, docs/editorial-style.md, docs/securite-ia.md et, si nécessaire, docs/diagrammes.md.

Objectif : <objectif éditorial en une phrase>
Slug : <slug>
Titre : <titre>
Description : <description>
Tags : <tags CSV>

Notes et sources autorisées :
<notes publiques et expurgées uniquement>

Contraintes :
- Écris en français pour des praticiens, avec la voix décrite dans la section « Signature personnelle » : récit concret, oralité légère, autodérision et humour parcimonieux.
- Utilise `je` uniquement pour les expériences présentes dans les notes et `tu` pour t’adresser au lecteur ; ne mélange pas les deux registres dans une même explication.
- N’invente ni expérience, ni commande, ni version, ni résultat, ni source.
- Signale clairement les hypothèses ou les informations manquantes.
- Ne lis aucun fichier hors de drafts/, templates/ et docs/.
- Pour un diagramme d’architecture, crée un fichier Mermaid `.mmd`, génère un SVG local et référence ce SVG ; n’utilise pas d’ASCII art.
- Ne modifie pas src/, static/, .github/ ou la configuration.
- Ne publie pas et n’effectue aucun appel réseau.
- Si `type: post`, termine le brouillon exactement par `**Ka-chow** 🚀`, sans texte après.
- Termine par une courte liste des hypothèses restantes, si nécessaire.
```
