---
title: "Pocket ID et Caddy : des passkeys pour mes applications auto-hébergées"
date: 2026-10-30 23:28:28
description: "Retour d’expérience sur Pocket ID et Caddy pour centraliser l’authentification des applications de mon home server avec des passkeys."
type: post
tags: pocket-id,caddy,oidc,passkeys,home-server
slug: pocket-id-caddy
---

# Pocket ID et Caddy : des passkeys pour mes applications auto-hébergées

À chaque nouvelle application sur mon home server, je retrouvais le même problème : créer un compte pour chaque personne du foyer, puis lui transmettre ses identifiants. Pour quelques services, ça va. Quand les applications se multiplient, gérer tous ces comptes et leurs mots de passe devient vite pénible.

En plus, dès qu’une application est accessible depuis Internet, il faut réfléchir à sa protection. Je cherchais donc une solution simple pour centraliser l’authentification, si possible sans mot de passe. C’est comme ça que je suis arrivé à [Pocket ID](https://pocket-id.org/).

## Une identité pour plusieurs applications

Pocket ID est un fournisseur d’identité OpenID Connect (OIDC). Il permet aux utilisateurs de se connecter avec une passkey enregistrée sur leur appareil, dans un gestionnaire de mots de passe ou sur une clé de sécurité. Chaque personne dispose d’un compte Pocket ID, mais n’a plus besoin de retenir un mot de passe différent pour chaque application protégée de cette manière.

Mon besoin reste modeste : je veux donner accès à mes applications personnelles et open source aux personnes de mon foyer. Je ne prévois pas d’ouvrir un espace de coworking dans mon salon. Pour ce petit nombre d’utilisateurs, Pocket ID répond bien à ce que je cherchais : un point d’authentification commun, avec des passkeys plutôt que des mots de passe à partager.

Attention, centraliser la connexion ne supprime pas forcément les comptes dans les applications. Une application qui gère ses propres utilisateurs, permissions ou données personnelles peut toujours avoir besoin d’un compte local, associé ou non à l’identité OIDC. Protéger l’accès avec Caddy ne lui apprend pas automatiquement qui est connecté ni quels droits lui attribuer.

## Mon architecture avec Proxmox et Caddy

Sur mon Proxmox, Caddy tourne dans un conteneur LXC sous Debian 13. Il est exposé sur Internet par une redirection de ma box et sert de reverse proxy pour mes services. Pocket ID tourne dans un autre conteneur LXC, installé à l’aide du paquet communautaire indiqué dans la [documentation Proxmox de Pocket ID](https://pocket-id.org/docs/setup/installation#proxmox).

Pour accéder à une application protégée, le navigateur arrive d’abord sur Caddy. S’il n’a pas de session autorisée, il passe par le portail d’authentification, qui utilise Pocket ID comme fournisseur OIDC. Une fois la connexion et les contrôles d’accès effectués, Caddy relaie la requête vers l’application.

Le fonctionnement dépend de la disponibilité de Caddy et de Pocket ID : si le fournisseur d’identité est indisponible, une nouvelle connexion peut être impossible. Les sessions déjà établies peuvent, elles, rester valides jusqu’à leur expiration selon la configuration.

## Relier une application à Pocket ID avec Caddy

Caddy est déjà le point d’entrée de mes services. Pour les applications que je protège au niveau du proxy, j’utilise le module `caddy-security` avec Pocket ID. Ce module n’est pas inclus dans la distribution standard de Caddy : il faut une installation qui l’intègre. La [documentation Pocket ID sur les services proxy](https://pocket-id.org/docs/guides/proxy-services) sert de point de départ pour l’intégration.

Le principe est le suivant :

1. Créer un client OIDC dans Pocket ID pour l’application, avec l’URL de redirection attendue par le portail Caddy. Vérifie sa valeur exacte dans la documentation et dans ta configuration : elle doit correspondre à celle enregistrée dans Pocket ID.
2. Fournir l’identifiant et le secret du client à Caddy par des variables d’environnement accessibles à son service, sans les écrire en clair dans le Caddyfile ni les publier.
3. Configurer le fournisseur OIDC, le portail et la politique d’autorisation dans Caddy, puis placer l’application derrière cette politique.
4. Recharger Caddy selon la méthode utilisée par ton installation, après avoir vérifié sa configuration.

Voici une version simplifiée de ma configuration pour une application. Les domaines `example.invalid` et les adresses `192.0.2.0/24` sont réservés aux exemples : remplace-les par tes propres valeurs. Cet extrait illustre le montage, mais n’a pas été testé tel quel. Les noms des variables d’environnement sont également des exemples.

```caddy
{
    order authenticate before respond

    security {
        oauth identity provider application {
            delay_start 3
            realm application
            driver generic
            client_id {env.POCKETID_CLIENT_ID}
            client_secret {env.POCKETID_CLIENT_SECRET}
            scopes openid email profile
            base_auth_url https://id.example.invalid
            metadata_url https://id.example.invalid/.well-known/openid-configuration
        }

        authentication portal application_portal {
            crypto default token lifetime 3600
            enable identity provider application
            cookie insecure off
            trust login redirect uri domain exact app.example.invalid path prefix /

            transform user {
                match realm application
                action add role user
            }
        }

        authorization policy application_policy {
            set auth url /caddy-security/
            allow roles user
        }
    }
}

id.example.invalid {
    reverse_proxy 192.0.2.10:1411
}

app.example.invalid {
    @auth {
        path /caddy-security /caddy-security/*
    }

    route {
        route @auth {
            authenticate with application_portal
        }
        authorize with application_policy
        reverse_proxy 192.0.2.20:8080
    }
}
```

La configuration définit un fournisseur OIDC pour ce client, un portail de connexion et une politique d’autorisation. Le portail associe le rôle `user` aux utilisateurs du realm configuré ; la politique accepte ce rôle avant de transmettre les autres requêtes à l’application. Le chemin `/caddy-security/` est réservé au portail. Le jeton du portail a ici une durée de vie de 3 600 secondes.

Ce rôle ne distingue pas les membres du foyer entre eux : dans cet exemple, il est attribué aux utilisateurs authentifiés par ce fournisseur. Limite donc l’accès au client Pocket ID aux personnes ou groupes concernés et vérifie les permissions propres à l’application. Pour une autre application, il faut adapter le client OIDC, le portail, la politique et les domaines ; ne pars pas du principe que les mêmes droits conviennent partout.

Pour que ça fonctionne, les vrais noms de domaine doivent être résolvables et accessibles en HTTPS. Caddy doit aussi pouvoir atteindre les métadonnées OIDC de Pocket ID via l’URL indiquée, y compris depuis son LXC. L’exemple utilise HTTP entre Caddy et les services en amont : limite l’accès à ces flux sur un réseau de confiance ou protège-les aussi par TLS si ton réseau l’exige.

## Vérifier l’accès avant de l’exposer

Avant de considérer l’application comme protégée, je vérifierais au minimum ces cas :

- Sans session, l’accès à l’application doit passer par le portail, pas afficher directement l’application.
- Une personne autorisée doit pouvoir se connecter avec sa passkey et atteindre le service. Une personne non autorisée doit être refusée.
- L’application ne doit pas être accessible en contournant Caddy, par exemple directement sur son port depuis Internet ou depuis un réseau non autorisé.
- Après déconnexion et expiration de session, reteste l’accès. La suppression d’un utilisateur ou de ses droits dans Pocket ID ne signifie pas nécessairement qu’une session Caddy déjà émise disparaît immédiatement.

Toutes les routes ne sont pas forcément protégées. Dans ma configuration Umami, par exemple, le script de suivi et l’envoi des événements restent accessibles sans connexion, tandis que le reste passe par la politique d’autorisation. C’est nécessaire pour la collecte, mais ce sont bien des points d’entrée publics : il faut les garder à jour et tenir compte de leur exposition.

## Ce que Pocket ID ne remplace pas

Pocket ID et Caddy ajoutent une barrière d’authentification ; ils ne corrigent pas les vulnérabilités des applications, ne remplacent pas leurs permissions internes et ne protègent pas un service accessible autrement que par le proxy. Il faut toujours maintenir les composants à jour, limiter les accès réseau et surveiller ce qui est exposé.

Pocket ID devient aussi un service central à sauvegarder et à restaurer. Prévois une procédure de récupération pour les comptes et les passkeys, teste-la avant d’en avoir besoin et conserve les sauvegardes nécessaires de façon sécurisée. Une personne qui perd son seul moyen de connexion ne doit pas découvrir à ce moment-là que personne ne sait rétablir son accès.

Pour mon home server, le compromis me convient : une identité par personne, des passkeys pour se connecter et Caddy comme point d’entrée commun. La simplification est réelle pour l’usage quotidien, à condition de vérifier les accès et de garder un plan de secours pour le service d’identité.

**Ka-chow** 🚀
