# CESIZen — Projet d'évaluation CDA

[![CI](https://github.com/TimLps/CesiZen/actions/workflows/ci.yml/badge.svg)](https://github.com/TimLps/CesiZen/actions/workflows/ci.yml)
[![Quality Gate](https://sonarcloud.io/api/project_badges/measure?project=TimLps_CesiZen&metric=alert_status)](https://sonarcloud.io/summary/new_code?id=TimLps_CesiZen)

Application de **santé mentale grand public** réalisée dans le cadre du titre **Concepteur Développeur d'Applications**.

> CESIZen propose à ses utilisateurs un espace pour mieux comprendre leur santé mentale, suivre leurs émotions au quotidien et apprendre à gérer leur stress via des exercices guidés de cohérence cardiaque.

---

## Sous-projets

| Dossier | Stack | Rôle |
|---|---|---|
| **`api/`** | Laravel 11 + MariaDB + Sanctum + Swagger | API REST exposant toute la logique métier |
| **`mobile/`** | Flutter (Riverpod + GoRouter + Dio) | Application mobile Android / iOS pour les utilisateurs |
| **`backoffice/`** | Flutter Web (même stack) | Interface d'administration desktop |

Chaque sous-projet possède son propre `README.md` détaillé.

---

## Modules réalisés

Conformément au cahier des charges du sujet CESIZen :

| Module | Type CDA | Statut |
|---|---|---|
| Gestion des comptes utilisateurs (RGPD inclus) | **Obligatoire** | ✅ Implémenté |
| Pages d'information sur la santé mentale | **Obligatoire** | ✅ Implémenté |
| Tracker d'émotions (journal + rapport agrégé, hiérarchie niveau 1/2) | **Au choix** | ✅ Implémenté |

---

## Documents fournis

Dans le dossier `docs/` :

| Fichier | Description |
|---|---|
| **`INSTALLATION.md`** | Guide d'installation pas à pas des 3 sous-projets |
| **`CESIZen_Choix_Techniques.pdf`** | Comparatif d'architectures + justification du choix Laravel + Flutter |
| **`CESIZen_Cahier_de_Tests.pdf`** | Stratégie de test, scénarios unitaires/fonctionnels/recette + PV de recette |

Le fichier [`SECURITE.md`](SECURITE.md) à la racine recense les failles
identifiées, les corrections apportées et la justification des valeurs
retenues.

---

## Démarrage

La stack Docker se compose d'un fichier de base et d'un override par
environnement. `compose.yml` ne se lance jamais seul.

```bash
cp .env.example .env    # variables consommées par docker compose
```

### API — environnement de développement

```bash
docker compose -f compose.yml -f compose.dev.yml up -d --build
docker compose -f compose.yml -f compose.dev.yml exec app composer install

# Générer la clé applicative, puis la reporter dans APP_KEY du .env racine :
docker compose -f compose.yml -f compose.dev.yml exec app php artisan key:generate --show
docker compose -f compose.yml -f compose.dev.yml up -d

docker compose -f compose.yml -f compose.dev.yml exec app php artisan migrate --seed
```

API sur <http://localhost:8001>, Swagger sur `/api/documentation`.
Base joignable depuis un client SQL local sur le port `3307`.

### API — environnement de production

```bash
docker compose -f compose.yml -f compose.prod.yml up -d --build
docker compose -f compose.yml -f compose.prod.yml exec app php artisan migrate --force
```

API sur <http://localhost>. La base n'est pas exposée à l'extérieur.

### Différences entre les deux environnements

| | Développement | Production |
|---|---|---|
| Code | monté depuis l'hôte (`bind mount`) | copié dans l'image, immuable |
| `APP_DEBUG` | `true` | `false` |
| Dépendances Composer | complètes | `--no-dev --optimize-autoloader` |
| Port de la base | `3307` exposé sur l'hôte | aucun, réseau interne uniquement |
| Redémarrage | manuel | `unless-stopped` |

### Applications Flutter

Le back-office doit démarrer sur le port 3000 : c'est l'origine déclarée
dans `config/cors.php`. Sans `--web-port`, Flutter en choisit un au hasard
et le navigateur bloquera les appels à l'API.

```bash
cd mobile     && flutter pub get && flutter run                             # mobile
cd backoffice && flutter pub get && flutter run -d chrome --web-port=3000   # back-office
```

Comptes seedés : `admin@cesizen.fr` (administrateur) et `demo@cesizen.fr`
(utilisateur). Leurs mots de passe proviennent de `SEED_ADMIN_PASSWORD` et
`SEED_DEMO_PASSWORD`, à renseigner dans le `.env`. Si ces variables sont
vides, le seeder engendre un mot de passe aléatoire et l'affiche une seule
fois dans sa sortie.

---

## Tests

```bash
docker compose -f compose.yml -f compose.dev.yml exec app php artisan test
```

Les tests s'exécutent sur **MariaDB**, le même moteur qu'en production, avec
`RefreshDatabase` : les migrations sont rejouées à chaque test, sans effet de
bord. Les identifiants de la base de test viennent de `api/src/.env.testing`
(non versionné, un exemple est fourni dans `api/src/.env.testing.example`).

---

## Auteur

**Tim LOPES** — promotion CDA, mai 2026.
