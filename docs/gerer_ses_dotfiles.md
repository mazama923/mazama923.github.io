---
title: Gérer ses dotfiles
layout: default
parent: 📖 Presque une doc
categories: [docs]
tags: [env, dotfiles]
---

Bon avant, je gérais pas mes dotfiles... mais ça, c'était avant.

## Au début

Pendant 3 ans, je comptais sur mes sauvegardes Time Machine pour restaurer mes dotfiles.
Jusqu'à ce que j'aie une corruption d'une de mes sauvegardes. 💥

## On va dire au milieu

Je me suis mis après ça à gérer mes dotfiles avec un repo git.

Puis, pour chacun de mes fichiers, je faisais un lien symbolique vers chaque dotfile.

C'était long, chiant, et pas vraiment de méthodo sur où ranger les fichiers de config... c'était tout en vrac. 🤷

## On va dire un peu apres le milieu

J'ai voulu faire ça comme un pro et utiliser NIX.

Gérer toute la config de ma machine avec NIX et mes dotfiles.

Mais quelle horreur à configurer NIX pour que ça marche ! 😱

L'implémentation sur macOS demande d'avoir un volume en plus pour la config de NIX.

Franchement, même après avoir fini, c'était super... mais une vraie machine à gaz.

## Et maintenant, si on faisait simple ?

On va reprendre les bases.

J'ai besoin de quoi ?

- mes dotfiles
- versionner
- les ranger par dossiers pour pas que ça soit le bordel
- et si en plus je pouvais déployer en une commande ?

Et là, BIMMMMMM 💥, je regarde un live de [bashbunni](https://www.youtube.com/@bashbunni) et elle parle de STOW.

C'est simple et ça répond à tous mes besoins.

Comment ça marche ? [STOW](https://www.gnu.org/software/stow/manual/stow.html) est un petit binaire CLI pour créer des liens symboliques selon l'architecture du dossier où tu l'exécutes.

## Comment j'utilise STOW

J'ai donc créé un repo git où je stocke tous mes fichiers de config que je range par dossier.
Et dans chaque dossier, je crée l'arborescence de où doit être le fichier.

Voici un petit tree pour etre plus clair:

```tree
dotfiles/
├── .pre-commit-config.yaml
├── bat
│   └── .config
│       └── bat
│           └── themes
│               └── Catppuccin Latte.tmTheme
├── Brewfile
├── fish
│   └── .config
│       └── fish
│           ├── completions
│           │   ├── docker.fish
│           │   └── fisher.fish
│           ├── conf.d
│           │   └── rustup.fish
│           ├── config.fish
│           ├── fish_plugins
│           ├── fish_variables
│           ├── functions
│           │   ├── delds.fish
│           │   ├── fish_prompt.fish
│           │   ├── fish_prompt.fish_bck
│           │   └── fisher.fish
│           └── themes
│               ├── Catppuccin Frappe.theme
│               ├── Catppuccin Latte.theme
│               ├── Catppuccin Macchiato.theme
│               └── Catppuccin Mocha.theme
├── ghostty
│   └── Library
│       └── Application Support
│           └── com.mitchellh.ghostty
│               ├── config
│               └── shaders
│                   └── cursor_smear.glsl
├── git
│   └── .gitignore_global
├── kitty
│   └── .config
│       └── kitty
│           ├── current-theme.conf
│           ├── kitty.conf
│           └── kitty.conf.bak
├── LICENSE
├── Makefile
├── markdownlint
│   └── .markdownlint.yaml
├── posting
│   └── .config
│       └── posting
│           └── config.yaml
├── README.md
└── vim
    └── .vimrc
```

Il ne reste plus qu'à faire `stow */` et paff ! Ça fait des chocapic... euuuh des liens symboliques. 🍫

{: .note }
La structure de vos dossiers doit respecter l'emplacement de votre repo git sur votre machine car STOW déploie avec le chemin `../`. Pour ma part, mon repo est dans `~`.

Si tu veux t'inspirer, voici mon repo de [dotfiles](https://github.com/mazama923/dotfiles).

---

Donc voilà, vous savez tout !
Cette méthode marche bien pour moi. Si tu ne sauvegardes pas encore tes fichiers de config, teste STOW : tu gagneras beaucoup de temps au prochain reset de ta machine.

**Bon DevOps à tous !** 🚀
