# CESIZen — Guide d'installation

Ce guide décrit pas à pas comment installer et lancer les **trois sous-projets** de la plateforme CESIZen sur une machine de développement :

1. **API Laravel** (`api/`) — backend REST
2. **Application mobile** (`mobile/`) — Flutter Android/iOS
3. **Back-office Web** (`backoffice/`) — Flutter Web

---

## 1. Prérequis

### Indispensables

| Outil | Version minimale | Lien |
|---|---|---|
| **Docker Desktop** (ou Docker Engine + Compose) | 20+ | https://docs.docker.com/get-docker/ |
| **Flutter SDK** | 3.5+ | https://docs.flutter.dev/get-started/install |
| **Git** | 2.x | https://git-scm.com |

### Recommandés

- **Android Studio** (avec un émulateur Android API 33+) pour tester l'app mobile
- **VS Code** avec les extensions Flutter, Dart, PHP, et Docker
- **Xcode** (macOS uniquement) pour le build iOS

### Vérification rapide

```bash
docker --version
docker compose version
flutter --version
flutter doctor
```

`flutter doctor` ne doit signaler **aucune erreur bloquante**.

---

## 2. Installation de l'API Laravel

L'API est conteneurisée pour éviter d'avoir à installer PHP, Composer et MariaDB sur la machine hôte.

### 2.1. Configuration de l'environnement

Les fichiers `compose` sont à la **racine du dépôt**, et lisent leurs
variables dans un `.env` situé au même endroit.

```bash
cd cesizen
cp .env.example .env
```

Renseigner ensuite les mots de passe de la base, puis `SEED_ADMIN_PASSWORD`
et `SEED_DEMO_PASSWORD` si l'on veut choisir ceux des comptes de
démonstration.

### 2.2. Lancement des conteneurs

Un socle commun et un fichier de surcharge par environnement.
`compose.yml` ne se lance jamais seul.

```bash
docker compose -f compose.yml -f compose.dev.yml up -d --build
```

Trois conteneurs démarrent :

| Conteneur | Rôle | Port hôte |
|---|---|---|
| `cesizen-app` | PHP 8.4-FPM + Laravel | — (interne) |
| `cesizen-web` | Nginx, frontal de php-fpm | 8001 |
| `cesizen-db` | MariaDB 11 | 3307 |

Aucune interface d'administration de base de données n'est exposée : la
base se consulte avec un client SQL local sur le port `3307`.

Pour la stack de production, remplacer `compose.dev.yml` par
`compose.prod.yml`. L'API écoute alors sur le port 80, le débogage est
désactivé, le code est figé dans l'image et la base n'est plus exposée.

### 2.3. Installation des dépendances PHP

```bash
docker compose -f compose.yml -f compose.dev.yml exec app composer install
```

### 2.4. Génération de la clé d'application

La clé est fournie par le `.env` de la racine, que lit `compose`. On la
génère donc sans l'écrire, puis on la reporte dans `APP_KEY`.

```bash
docker compose -f compose.yml -f compose.dev.yml exec app php artisan key:generate --show
# coller la valeur dans APP_KEY du .env racine, puis :
docker compose -f compose.yml -f compose.dev.yml up -d
```

### 2.5. Création du schéma BDD et chargement des données initiales

```bash
docker compose -f compose.yml -f compose.dev.yml exec app php artisan migrate --seed
```

Cette commande :
- Crée toutes les tables (`users`, `roles`, `emotions`, `journal_entries`…)
- Insère les rôles, états, le référentiel d'émotions et 5 pages d'information
- Crée 2 comptes utilisateur (admin + démo)

### 2.6. Génération de la documentation Swagger

```bash
docker compose -f compose.yml -f compose.dev.yml exec app php artisan l5-swagger:generate
```

### 2.7. Vérification

| URL | Attendu |
|---|---|
| http://localhost:8001/api/health | `{"status":"ok","service":"CESIZen API"}` |
| http://localhost:8001/api/documentation | Swagger UI interactif |

### Comptes pré-créés

| Email | Rôle |
|---|---|
| `admin@cesizen.fr` | Administrateur |
| `demo@cesizen.fr` | Utilisateur |

Leurs mots de passe proviennent de `SEED_ADMIN_PASSWORD` et
`SEED_DEMO_PASSWORD`. Si ces variables sont vides, le seeder engendre un
mot de passe aléatoire et l'affiche **une seule fois** dans sa sortie —
le noter à ce moment-là.

### Lancer les tests automatisés

```bash
docker exec -it cesizen_app php artisan test
```

Sortie attendue : tous les tests verts (PASS).

---

## 3. Installation de l'application mobile

L'API doit être lancée et accessible sur `localhost:8001` avant de démarrer l'app mobile.

### 3.1. Installation des dépendances

```bash
cd cesizen/mobile
flutter pub get
```

### 3.2. Choix de la plateforme cible

#### Option A — Émulateur Android (recommandé)

1. Ouvrir **Android Studio** → AVD Manager → créer un émulateur (API 33+)
2. Lancer l'émulateur
3. Vérifier qu'il apparaît dans la liste :

```bash
flutter devices
```

#### Option B — Appareil physique Android

1. Activer le **mode développeur** sur le téléphone
2. Activer le **débogage USB**
3. Brancher en USB
4. Si l'API tourne sur la même machine, configurer l'app pour pointer vers l'IP du PC dans `lib/core/network/api_client.dart`

#### Option C — iOS (macOS uniquement)

```bash
open -a Simulator
flutter devices  # iPhone simulator doit apparaître
```

#### Option D — Web (pour démo rapide)

```bash
flutter run -d chrome --web-port=3001
```

Le port n'est pas optionnel : `3001` est l'origine déclarée pour
l'application mobile dans `config/cors.php` — le back-office occupe `3000`.
Sans `--web-port`, Flutter en choisit un au hasard et le navigateur bloque
les appels à l'API au titre de la politique CORS.

### 3.3. Lancement

```bash
flutter run
```

> **Astuce** : Sur émulateur Android, l'app communique avec l'API via `http://10.0.2.2:8001` (IP magique d'Android pour atteindre l'hôte). C'est automatique, aucune configuration nécessaire.

### 3.4. Connexion

Sur l'écran de login, utilisez `demo@cesizen.fr` / `password` (ou créez un nouveau compte). Vous pouvez aussi cliquer sur **"Continuer en visiteur"** pour explorer les pages d'information et la cohérence cardiaque sans authentification.

---

## 4. Installation du back-office Web

### 4.1. Activation du support Web (une seule fois)

```bash
flutter config --enable-web
```

### 4.2. Installation des dépendances

```bash
cd cesizen/backoffice
flutter pub get
```

### 4.3. Lancement

```bash
flutter run -d chrome --web-port=3000
```

Le port 3000 n'est pas optionnel : c'est l'origine déclarée pour le
back-office dans `config/cors.php`. Sans `--web-port`, Flutter en choisit
un au hasard et le navigateur bloque les appels à l'API.

Une fenêtre Chrome s'ouvre automatiquement avec hot-reload activé.

### 4.4. Connexion

Seuls les **administrateurs** peuvent se connecter au back-office :

| Email | Mot de passe |
|---|---|
| `admin@cesizen.fr` | `password` |

Toute tentative avec un compte utilisateur standard est refusée avec un message explicite.

---

## 5. Vue d'ensemble des URLs

Une fois la stack complète démarrée :

| Service | URL | Authentification |
|---|---|---|
| API Laravel | http://localhost:8001 | Sanctum (jeton Bearer) |
| Documentation Swagger | http://localhost:8001/api/documentation | — |
| Base de données | `localhost:3307` | client SQL local |
| Mobile (web debug) | http://localhost:NNNN | Sanctum |
| Back-office | http://localhost:NNNN | Sanctum (admin uniquement) |

> Les ports des apps Flutter sont attribués dynamiquement par `flutter run`.

---

## 6. Arrêt et nettoyage

### Arrêter Docker

```bash
cd cesizen/api
docker compose down            # Arrête les conteneurs (préserve les données)
docker compose down -v         # Arrête ET supprime le volume BDD (reset complet)
```

### Nettoyer Flutter

```bash
flutter clean
flutter pub get
```

---

## 7. Résolution des problèmes courants

### L'API renvoie une erreur 500

```bash
docker exec -it cesizen_app php artisan migrate:fresh --seed
docker exec -it cesizen_app php artisan config:clear
docker exec -it cesizen_app php artisan cache:clear
```

### L'app mobile ne se connecte pas à l'API

- Sur **émulateur Android**, l'URL doit être `10.0.2.2:8001`, pas `localhost:8001`. C'est automatique dans `api_client.dart`.
- Sur **appareil physique**, modifier `lib/core/network/api_client.dart` pour pointer vers l'IP du PC (ex. `192.168.1.42:8001`).
- Vérifier que le pare-feu autorise les connexions sur le port 8001.

### `flutter run` échoue avec « No application found »

```bash
flutter clean
flutter pub get
flutter run
```

### La base n'accepte pas les connexions au démarrage

Le conteneur MariaDB met quelques secondes à s'initialiser. `compose.yml`
déclare une sonde de santé et le service `app` attend qu'elle passe au
vert, mais un client SQL lancé immédiatement après `docker compose up`
peut arriver trop tôt. Attendre une dizaine de secondes.

### Réinitialiser complètement

```bash
cd cesizen/api
docker compose down -v
docker compose up -d --build
docker exec -it cesizen_app composer install
docker exec -it cesizen_app php artisan key:generate
docker exec -it cesizen_app php artisan migrate --seed
docker exec -it cesizen_app php artisan l5-swagger:generate
```

---

## 8. Structure du dépôt

```
cesizen/
├── api/                        # API Laravel
│   ├── docker/                (Dockerfile PHP et Nginx)
│   ├── docker/php/Dockerfile
│   ├── src/                    # Code source Laravel
│   └── README.md
├── mobile/                     # App Flutter (Android/iOS/Web)
│   ├── lib/
│   ├── pubspec.yaml
│   └── README.md
├── backoffice/                 # Back-office Flutter Web
│   ├── lib/
│   ├── pubspec.yaml
│   ├── web/
│   └── README.md
└── docs/                       # Livrables PDF
    ├── CESIZen_Choix_Techniques.pdf
    ├── CESIZen_Cahier_de_Tests.pdf
    └── INSTALLATION.md         # ← ce document
```

---

## 9. Pour aller plus loin

- **`api/README.md`** : architecture interne de l'API, modules et endpoints
- **`mobile/README.md`** : structure du code Flutter mobile et choix de UI
- **`backoffice/README.md`** : modules administrables et conventions de design
- **`docs/CESIZen_Choix_Techniques.pdf`** : justification du choix Laravel + Flutter
- **`docs/CESIZen_Cahier_de_Tests.pdf`** : scénarios de test et procès-verbal de recette
