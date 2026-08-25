# CESIZen — Mobile (Flutter)

Application mobile **CESIZen** : santé mentale, journal d'émotions.

Cible : Android et iOS (un seul codebase Dart). Compatible Web pour la démo.

## Stack technique

- **Flutter SDK ≥ 3.5** (Dart 3.5)
- **Riverpod 2** — gestion d'état
- **GoRouter 14** — navigation déclarative + redirections par auth guard
- **Dio 5** — client HTTP avec intercepteur Sanctum
- **shared_preferences** — persistance du token
- **google_fonts (Montserrat)** — typographie
- **flutter_html** — rendu des pages d'information éditoriales
- **fl_chart** + dessins custom — visualisations

## Démarrage rapide

### Prérequis

- [Flutter SDK 3.5+](https://docs.flutter.dev/get-started/install)
- API CESIZen en cours d'exécution (cf. `api/README.md`)
- Un émulateur Android (préférable) ou un appareil physique

### Lancer l'app

```bash
cd mobile
flutter pub get
flutter run
```

### URLs de l'API (auto-détection)

L'application choisit automatiquement la bonne URL selon la plateforme :

| Plateforme | URL utilisée |
|---|---|
| Android émulateur | `http://10.0.2.2:8001/api` |
| iOS simulateur / Web / Desktop | `http://localhost:8001/api` |

Pour viser un autre serveur, modifier `lib/core/network/api_client.dart`.

### Comptes de test

| Email | Mot de passe | Rôle |
|---|---|---|
| `admin@cesizen.fr` | `password` | Administrateur |
| `demo@cesizen.fr` | `password` | Utilisateur |

## Structure du projet

```
lib/
├── main.dart                     # Point d'entrée + ProviderScope
├── core/
│   ├── theme/
│   │   └── app_theme.dart        # Palette pastel CESIZen + ThemeData
│   ├── network/
│   │   ├── api_client.dart       # Dio + auto-détection baseUrl
│   │   └── auth_interceptor.dart # Bearer token Sanctum
│   ├── router/
│   │   └── app_router.dart       # GoRouter + auth guard
│   └── layout/
│       └── main_scaffold.dart    # Bottom nav 3 onglets
├── models/                       # User, Emotion, JournalEntry, InfoPage…
├── services/                     # Couche API (un Dio par service)
├── providers/                    # Riverpod : authProvider + FutureProviders
├── pages/
│   ├── auth/                     # login, register, forgot-password
│   ├── home/                     # Page Accueil (smiley + rapport semaine)
│   ├── info/                     # Liste + détail des pages d'info
│   ├── journal/                  # Journal + ajout/édition d'entrée
│   ├── breathing/                # Liste + lecteur cohérence cardiaque
│   └── profile/                  # Profil + édition
└── widgets/                      # CesiLogo, états (loading/error/empty)
```

## Fonctionnalités

### Front-Office (visiteur anonyme)

- 📰 **Pages d'information** — comprendre le stress, la santé mentale, les émotions
- 🌬️ **Cohérence cardiaque** — 3 exercices guidés (7-4-8, 5-5, 4-6) avec animation respiratoire

### Front-Office (utilisateur connecté)

- 📅 **Journal d'émotions** — saisie, modification, suppression
- 📊 **Rapport** — agrégation par catégorie sur une période (semaine / mois / plage personnalisée)
- 🏠 **Page Accueil** — vue synthétique : émotion dominante, top 3 catégories de la semaine
- 👤 **Profil** — édition + suppression de compte (RGPD)

## Architecture

```
┌─────────────────────────────────────────┐
│  Pages (UI Flutter)                     │
└──────────────┬──────────────────────────┘
               ▼
┌─────────────────────────────────────────┐
│  Providers (Riverpod)                   │
│  - authProvider (Notifier)              │
│  - FutureProvider.family                │
└──────────────┬──────────────────────────┘
               ▼
┌─────────────────────────────────────────┐
│  Services (Dio)                         │
│  - AuthService, JournalService, etc.    │
└──────────────┬──────────────────────────┘
               ▼
┌─────────────────────────────────────────┐
│  Models (Dart classes + fromJson)       │
└─────────────────────────────────────────┘
```

## Commandes utiles

```bash
# Lancer en mode dev avec hot reload
flutter run

# Lancer sur Chrome (web) — le port est imposé par la politique CORS de
# l'API : 3001 pour l'application mobile, 3000 étant pris par le back-office
flutter run -d chrome --web-port=3001

# Build release Android (APK)
flutter build apk --release

# Build release iOS (IPA)
flutter build ipa --release

# Tests
flutter test
```
