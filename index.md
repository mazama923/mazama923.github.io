---
title: Home
layout: home
nav_order: 1
last_modified_date: Nov 12 2025
---

# 🚀 Bienvenue sur mon Blog

## 👋 Qui suis-je ?

| Je suis passionné de **DevOps** et je partage ici mes expériences, mes POCs (Proof of Concept) et mes apprentissages dans le monde de l'infrastructure moderne. | ![my memoji](./assets/images/memoji.avif) |

## 🎯 Ce que vous trouverez ici

### 📝 Des posts

Des articles chronologiques sur mes expérimentations, destinés à partager mes découvertes plutôt qu'à servir de tutoriels détaillés.

- **POCs** : Tests d'outils et de technologies
- **Retours d'expérience** : Ce qui fonctionne (ou pas !)
- **Best practices** : Conseils et astuces du terrain
- **Mes découvertes** : Partager avec vous mes travaux qui ne seront peut-être pas nouveaux pour vous, mais qui reflètent mon parcours d'apprentissage

### 🛠️ Docs plus formelles

Je partagerai ici comment j'ai mis en place certains outils ainsi que des retours d'expérience qui, selon moi, méritent plus qu'un simple post.

- 🐳 **Conteneurisation** : Docker
- ☸️ **Orchestration** : Kubernetes, Helm
- 🏗️ **IaC** : Ansible
- 🔄 **CI/CD** : GitLab CI, GitHub Actions
- 📊 **Monitoring** : Prometheus, Grafana
- 🧰 **Tooling en général** : Des outils qui m'aident au quotidien

## 📚 Mes posts récents

{% for post in site.posts limit:5 %}

### [{{ post.title }}]({{ post.url }})

**{{ post.date | date: "%d %B %Y" }}** - {{ post.categories | join: ", " }}

---

{{ post.excerpt }}

[Lire la suite →]({{ post.url }})

{% endfor %}
