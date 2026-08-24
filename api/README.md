# CESIZen — API Laravel

API REST pour l'application **CESIZen** : santé mentale, journal d'émotions.

## Stack technique

- **PHP 8.4** + **Laravel 11**
- **MariaDB 11** (compatible MySQL 8)
- **Laravel Sanctum** — authentification par tokens
- **L5-Swagger** (darkaonline) — documentation OpenAPI auto-générée
- **PHPUnit 11** — tests unitaires et fonctionnels
- Architecture **MVC + Repository Pattern + Service Layer**

## Démarrage rapide

### Prérequis

- Docker + Docker Compose
- (ou en local : PHP 8.2+, Composer, MariaDB)

### Lancement avec Docker

```bash
# 1. Copier le fichier d'environnement
cp src/.env.example src/.env

# 2. Construire et lancer les conteneurs
docker compose up -d --build

# 3. Installer les dépendances Composer
docker exec -it cesizen_app composer install

# 4. Générer la clé d'application
docker exec -it cesizen_app php artisan key:generate

# 5. Lancer les migrations + seeders
docker exec -it cesizen_app php artisan migrate --seed

# 6. (optionnel) Générer la documentation Swagger
docker exec -it cesizen_app php artisan l5-swagger:generate
```

L'API est ensuite accessible sur :
- **API**            → http://localhost:8001
- **Documentation**  → http://localhost:8001/api/documentation
- **phpMyAdmin**     → http://localhost:8081 (root / root)

### Comptes seedés

| Email | Mot de passe | Rôle |
|---|---|---|
| `admin@cesizen.fr` | `password` | Administrateur |
| `demo@cesizen.fr`  | `password` | Utilisateur |

## Structure de l'API

### Modules

| Module | Routes | Acteur |
|---|---|---|
| **Authentification** | `/api/auth/*` | Public + Sanctum |
| **Profil** | `/api/profile` | Utilisateur connecté |
| **Informations** | `/api/info-pages` | Public |
| **Émotions (référentiel)** | `/api/emotion-categories` | Connecté |
| **Journal d'émotions** | `/api/journal` | Connecté |
| **Admin — Utilisateurs** | `/api/admin/users` | Admin |
| **Admin — Pages** | `/api/admin/info-pages` | Admin |
| **Admin — Émotions** | `/api/admin/emotion-categories`, `/api/admin/emotions` | Admin |
| **Admin — Dashboard** | `/api/admin/dashboard` | Admin |

### Architecture des couches

```
┌─────────────────────────────────────────┐
│  Routes (routes/api.php)                │
└──────────────┬──────────────────────────┘
               ▼
┌─────────────────────────────────────────┐
│  Controllers (App\Http\Controllers\Api) │
│  - Validation via FormRequest           │
│  - Sérialisation via Resource           │
└──────────────┬──────────────────────────┘
               ▼
┌─────────────────────────────────────────┐
│  Services (App\Services)                │
│  - Logique métier                       │
└──────────────┬──────────────────────────┘
               ▼
┌─────────────────────────────────────────┐
│  Repositories (App\Repositories)        │
│  - Accès aux données                    │
└──────────────┬──────────────────────────┘
               ▼
┌─────────────────────────────────────────┐
│  Models (App\Models) — Eloquent         │
└─────────────────────────────────────────┘
```

## Sécurité

- Mots de passe **hashés via Bcrypt** (cast `hashed` automatique)
- **Sanctum** pour les tokens API (révocation automatique sur logout)
- **Soft-delete** sur les utilisateurs (RGPD : effacement réversible)
- Middleware **role** pour le cloisonnement Admin / User
- **HTTPS** obligatoire en production (déjà configuré côté reverse-proxy)

## Tests

```bash
# Tous les tests
docker exec -it cesizen_app php artisan test

# Uniquement les tests unitaires
docker exec -it cesizen_app php artisan test --testsuite=Unit

# Uniquement les tests fonctionnels
docker exec -it cesizen_app php artisan test --testsuite=Feature
```

## Variables d'environnement principales

Voir `.env.example` pour la liste complète. Les principales :

| Clé | Description |
|---|---|
| `APP_KEY` | Générée via `php artisan key:generate` |
| `DB_HOST` | `db` (Docker) ou `127.0.0.1` (local) |
| `DB_DATABASE` | `cesizen` |
| `SANCTUM_STATEFUL_DOMAINS` | Domaines autorisés pour le SPA back-office |
| `MAIL_MAILER` | `log` en dev, `smtp` en prod |
