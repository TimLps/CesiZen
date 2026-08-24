# CESIZen — Projet d'évaluation CDA Bloc 2

Application de **santé mentale grand public** réalisée dans le cadre du titre **Concepteur Développeur d'Applications** (Bloc 2 — *Développer et tester les applications informatiques*).

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

---

## Démarrage en 3 commandes

```bash
# 1. Lancer l'API (Docker)
cd api && cp src/.env.example src/.env && docker compose up -d --build
docker exec -it cesizen_app composer install
docker exec -it cesizen_app php artisan key:generate
docker exec -it cesizen_app php artisan migrate --seed

# 2. Lancer l'app mobile (sur émulateur Android lancé)
cd ../mobile && flutter pub get && flutter run

# 3. Lancer le back-office (autre terminal)
cd ../backoffice && flutter pub get && flutter run -d chrome
```

URLs : API sur `http://localhost:8001`, Swagger sur `/api/documentation`, phpMyAdmin sur `:8081`.

Comptes seedés :
- `admin@cesizen.fr` / `password` (admin)
- `demo@cesizen.fr` / `password` (utilisateur)

---

## Auteur

**Tim LOPES** — promotion CDA, mai 2026.
