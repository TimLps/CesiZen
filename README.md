# CESIZen

Application de gestion du stress et de suivi des émotions.
API REST **Laravel 11** (authentification **Sanctum**), application mobile **Flutter**,
back-office d'administration **Flutter Web**.

## Arborescence

| Dossier | Contenu |
|---|---|
| `api/` | API REST Laravel 11. Le code applicatif est dans `api/src`, l'outillage Docker dans `api/docker`. |
| `mobile/` | Application Flutter (Android / iOS). |
| `backoffice/` | Application Flutter Web d'administration. |
| `docs/` | Architecture, installation, RGAA, cahier de tests. |

## Prérequis

Docker et le plugin Docker Compose. Rien d'autre : PHP, Composer et MariaDB
tournent dans les conteneurs.

## Démarrage

La stack se compose d'un fichier de base et d'un override par environnement.
`compose.yml` ne se lance jamais seul.

```bash
cp .env.example .env          # puis renseigner les mots de passe
```

### Développement

Code monté depuis l'hôte (modification sans rebuild), `APP_DEBUG` actif,
base de données joignable depuis un client SQL local sur le port `3307`.

```bash
docker compose -f compose.yml -f compose.dev.yml up -d --build
docker compose -f compose.yml -f compose.dev.yml exec app php artisan key:generate
docker compose -f compose.yml -f compose.dev.yml exec app php artisan migrate --seed
```

API disponible sur <http://localhost:8000>. Vérification : <http://localhost:8000/api/health>.

### Production

Code figé dans l'image, `APP_DEBUG` désactivé, dépendances de développement
absentes, base non exposée à l'extérieur, redémarrage automatique des conteneurs.

```bash
docker compose -f compose.yml -f compose.prod.yml up -d --build
docker compose -f compose.yml -f compose.prod.yml exec app php artisan migrate --force
```

API disponible sur <http://localhost>.

### Différences entre les deux environnements

| | Développement | Production |
|---|---|---|
| Code | monté depuis l'hôte (`bind mount`) | copié dans l'image, immuable |
| `APP_DEBUG` | `true` | `false` |
| Dépendances Composer | complètes | `--no-dev --optimize-autoloader` |
| Port de la base | `3307` exposé sur l'hôte | aucun, réseau interne uniquement |
| Redémarrage | manuel | `unless-stopped` |

## Tests

```bash
docker compose -f compose.yml -f compose.dev.yml exec app php artisan test
```

Les tests s'exécutent sur **MariaDB**, le même moteur qu'en production, avec
`RefreshDatabase` : les migrations sont rejouées à chaque test, sans effet de
bord. Les identifiants de la base de test viennent de `api/src/.env.testing`
(non versionné, un exemple est fourni).

## Documentation de l'API

La spécification OpenAPI est générée par `l5-swagger` à partir des attributs PHP
des contrôleurs, et exposée sur `/api/documentation` en environnement de
développement.
