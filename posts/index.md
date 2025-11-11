---
title: 📬 La poste
layout: default
nav_order: 3
last_modified_date: Nov 7 2025
---

## 📚 Tous mes posts

Ici tu trouveras tous mes posts classés par ordre chronologique.
*Promis, ils sont tous plus passionnants les uns que les autres... enfin presque !* 😉

{% for post in site.posts %}

### [{{ post.title }}]({{ post.url }})

**{{ post.date | date: "%d %B %Y" }}** - {{ post.categories | join: ", " }}

{% endfor %}

---

*PS : Si tu ne trouves pas ce que tu cherches, c'est sûrement que je ne l'ai pas encore écrit... ou que j'ai oublié de publier !* 📝
