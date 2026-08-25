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
- (ou en local : PHP 8.4, Composer, MariaDB)

### Lancement avec Docker

Les fichiers `compose` sont **à la racine du dépôt**, pas dans `api/`. Un
socle commun et un fichier de surcharge par environnement ; `compose.yml`
ne se lance jamais seul.

```bash
# depuis la racine du dépôt
cp .env.example .env    # puis renseigner les mots de passe

docker compose -f compose.yml -f compose.dev.yml up -d --build
docker compose -f compose.yml -f compose.dev.yml exec app composer install

# Générer la clé, puis la reporter dans APP_KEY du .env racine :
docker compose -f compose.yml -f compose.dev.yml exec app php artisan key:generate --show
docker compose -f compose.yml -f compose.dev.yml up -d

docker compose -f compose.yml -f compose.dev.yml exec app php artisan migrate --seed
```

L'API est ensuite accessible sur :
- **API**            → http://localhost:8001
- **Documentation**  → http://localhost:8001/api/documentation

La base de données est joignable depuis un client SQL local sur le port
`3307`. Aucune interface d'administration web n'est exposée par la stack.

Pour la stack de production, voir le README à la racine du dépôt.

### Comptes seedés

| Email | Rôle |
|---|---|
| `admin@cesizen.fr` | Administrateur |
| `demo@cesizen.fr`  | Utilisateur |

Leurs mots de passe proviennent de `SEED_ADMIN_PASSWORD` et
`SEED_DEMO_PASSWORD`, à renseigner dans le `.env` de la racine. Si ces
variables sont vides, le seeder engendre un mot de passe aléatoire et
l'affiche **une seule fois** dans sa sortie.

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

- Mots de passe **hachés via Bcrypt** (cast `hashed` automatique)
- **Sanctum** — jetons opaques stockés hachés, révoqués à la déconnexion
- **Politique de mot de passe** centralisée : 12 caractères, majuscule et
  minuscule, chiffre, symbole, appliquée aux six points d'entrée
- **Limitation de débit** : 5 requêtes/min/IP sur les routes
  d'authentification, 60/min sur le reste de l'API
- **CORS** restreint aux origines du back-office
- **Soft-delete** sur les utilisateurs (RGPD : effacement réversible)
- Middleware **role** pour le cloisonnement Admin / User
- Authentification **par jeton uniquement** : l'authentification par
  session est désactivée, aucun client ne s'en sert

Le détail des failles identifiées et des corrections apportées se trouve
dans [`SECURITE.md`](../SECURITE.md) à la racine du dépôt.

> Le projet n'est pas déployé. La terminaison TLS relèverait de l'hôte de
> déploiement ; aucun reverse-proxy n'est fourni ni configuré dans ce
> dépôt.

## Tests

```bash
# depuis la racine du dépôt
docker compose -f compose.yml -f compose.dev.yml exec app php artisan test
docker compose -f compose.yml -f compose.dev.yml exec app php artisan test --testsuite=Unit
docker compose -f compose.yml -f compose.dev.yml exec app php artisan test --testsuite=Feature
```

Les tests s'exécutent sur **MariaDB**, le même moteur qu'en production.
Les identifiants de la base de test viennent de `.env.testing`
(non versionné, exemple fourni dans `.env.testing.example`).

## Variables d'environnement principales

Voir `.env.example` pour la liste complète. Les principales :

| Clé | Description |
|---|---|
| `APP_KEY` | Générée via `php artisan key:generate` |
| `DB_HOST` | `db` (Docker) ou `127.0.0.1` (local) |
| `DB_DATABASE` | `cesizen` |
| `SEED_ADMIN_PASSWORD` | Mot de passe du compte administrateur semé ; aléatoire si vide |
| `SEED_DEMO_PASSWORD` | Mot de passe du compte de démonstration semé ; aléatoire si vide |
| `MAIL_MAILER` | `log` en dev, `smtp` en prod |
