---
title: "Erreur Git : Could not read from remote repository sur macOS & Keychain"
date: 2025-11-18 00:00:00 Europe/Paris
description: "Résoudre une erreur d'accès Git SSH sur macOS en rechargeant une clé dans le Keychain."
slug: could-not-read-from-remote-repository
type: post
tags: git,ssh,keychain,macos,debug
---

## Could not read from remote repository

## Problème

En travaillant sur macOS, je me suis retrouvé face à l'erreur suivante en tentant de push/pull sur un dépôt GitHub :

```plaintext
fatal: Could not read from remote repository.
Please make sure you have the correct access rights
and the repository exists
```

Ma clé SSH était bien présente dans le *Keychain* et ma config `~/.ssh/config` correcte, mais l’erreur persistait.

## Diagnostic

- **Test SSH** réussi (`ssh -T git@github.com`)
- **Clé bien référencée dans le fichier ssh/config**
- **Clé privée dans le trousseau macOS**
- Mais Git rejetait l’accès en push/pull SSH.

Le problème :
Sur macOS, l’agent SSH peut “oublier” de charger automatiquement la clé présente dans le Keychain après un redémarrage ou une nouvelle session.

## Solution

Rechargez la clé dans l’agent SSH avec :

```bash
ssh-add --apple-use-keychain ~/.ssh/id_rsa_perso
```

Vérifiez avec :

```bash
ssh-add -l
```

Automatiser à chaque ouverture de terminal (zsh/bash/fish) :

```bash
ssh-add --apple-use-keychain ~/.ssh/id_rsa_perso 2>/dev/null
```

À placer dans `~/.zprofile`, `~/.bash_profile` ou `~/.config/fish/config.fish` selon votre shell.

## Remarques

- Ce souci est fréquent si vous gérez plusieurs identités SSH (perso, pro…).
- Toujours vérifier que la clé publique correspond bien à la clé privée chargée.

## Mémo rapide (snippet)

```bash
ssh-add --apple-use-keychain ~/.ssh/id_rsa_perso
git push # ça fonctionne !
```

---

J'espère que cela pourra vous aider ! Ce problème m'a bien pris la tête pendant un moment.

**Ka-chow** 🚀
