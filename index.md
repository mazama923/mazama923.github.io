---
title: Home
layout: home
nav_order: 1
---

{% if site.posts.size == 0 %}
*Aucun article pour le moment. Revenez bientôt !*
{% endif %}

---

# 🚀 Bienvenue sur mon Blog DevOps

## 👋 Qui suis-je ?

Je suis un passionné de **DevOps** et je partage ici mes expériences, mes POCs (Proof of Concepts) et mes apprentissages dans le monde de l'infrastructure moderne.

## 🎯 Ce que vous trouverez ici

### 📝 Articles de blog (Posts)
Des articles chronologiques sur mes expérimentations :
- **POCs DevOps** : Tests d'outils et de technologies
- **Tutoriels** : Guides pratiques étape par étape
- **Retours d'expérience** : Ce qui fonctionne (ou pas !)
- **Best practices** : Conseils et astuces du terrain

### 🛠️ Domaines couverts

- 🐳 **Conteneurisation** : Docker
- ☸️ **Orchestration** : Kubernetes, Helm
- 🏗️ **IaC** : Ansible
- 🔄 **CI/CD** : GitLab CI, GitHub Actions
- 📊 **Monitoring** : Prometheus, Grafana

## 📚 Articles récents

{% for post in site.posts limit:5 %}
### [{{ post.title }}]({{ post.url }})
**{{ post.date | date: "%d %B %Y" }}** - {{ post.categories | join: ", " }}

{{ post.excerpt }}

[Lire la suite →]({{ post.url }})

---
{% endfor %}
