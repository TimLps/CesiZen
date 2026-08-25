# CESIZen — Back-office (Flutter Web)

Interface d'administration de la plateforme **CESIZen** : pilotage des utilisateurs, des contenus éditoriaux, du référentiel d.émotions et des statistiques de la plateforme.

Cible : navigateur desktop (Chrome, Firefox, Edge, Safari).

## Stack technique

- **Flutter Web** (SDK ≥ 3.5)
- **Riverpod 2** — gestion d'état
- **GoRouter 14** — navigation + redirection auth admin-only
- **Dio 5** + intercepteur Sanctum
- **shared_preferences** — persistance du token
- **flutter_html** — preview live de l'éditeur de pages
- **fl_chart** — visualisations dashboard

## Démarrage rapide

### Prérequis

- Flutter SDK 3.5+ avec support Web activé
- API CESIZen accessible sur `http://localhost:8001`

> Le back-office doit démarrer sur le **port 3000** : c'est l'origine
> déclarée dans `api/src/config/cors.php`. Sans `--web-port=3000`, Flutter
> choisit un port au hasard et le navigateur bloque tous les appels à
> l'API au titre de la politique CORS.

```bash
# Vérifier que le support Web est actif
flutter config --enable-web
flutter devices  # Chrome doit apparaître
```

### Lancer le back-office

```bash
cd backoffice
flutter pub get
flutter run -d chrome --web-port=3000
```

L'application s'ouvre dans Chrome avec hot-reload activé.

### Compte d'accès

Seuls les utilisateurs ayant le rôle **admin** peuvent se connecter au back-office. La tentative de connexion d'un utilisateur standard est refusée avec un message explicite.

| Email | Mot de passe |
|---|---|
| `admin@cesizen.fr` | `password` |

## Structure du projet

```
lib/
├── main.dart                        # Entrée + ProviderScope
├── core/
│   ├── theme/admin_theme.dart       # Palette + ThemeData admin (sobre)
│   ├── network/                     # Dio + AuthInterceptor (token admin)
│   ├── router/admin_router.dart     # Guard admin-only
│   └── layout/admin_shell.dart      # Sidebar 260px + zone contenu
├── models/                          # User, EmotionCategory, InfoPage…
├── services/                        # Couche API admin (CRUD)
├── providers/                       # authProvider + FutureProviders
├── pages/
│   ├── auth/login_page.dart         # Login admin (split layout)
│   ├── dashboard/                   # KPIs et état plateforme
│   ├── users/                       # Table + CRUD utilisateurs
│   ├── info_pages/                  # Liste + éditeur HTML avec preview
│   ├── emotions/                    # Gestion référentiel (cat. + émotions)
│   ├── breathing/                   # CRUD exercices cohérence cardiaque
│   └── profile/admin_profile_page.dart
└── widgets/
    └── admin_widgets.dart           # AdminPageHeader, états
```

## Modules administrables

### Tableau de bord

6 KPI cards :
- **Utilisateurs** (total + actifs)
- **Nouveaux utilisateurs** (30 derniers jours)
- **Pages publiées** / total
- **Référentiel d'émotions** (catégories × émotions)
- **Entrées de journal** (total + 7 derniers jours)
- **Exercices de respiration** disponibles

Section "État de la plateforme" avec barres de progression :
- Taux d'utilisateurs actifs
- Taux de pages publiées vs total

### Utilisateurs

- Table paginée : ID, Nom, Email, Ville, Rôle, État, Date d'inscription
- Création de comptes (admin ou utilisateur)
- Modification (avec changement de mot de passe optionnel)
- Désactivation (l'utilisateur ne peut plus se connecter, données conservées)
- Suppression (soft-delete RGPD)

### Pages d'information

- Liste avec ordre, titre, slug, statut publié/brouillon
- Éditeur split-view :
  - Formulaire à gauche (titre, slug avec validation regex `[a-z0-9-]+`, libellé menu, ordre, switch publié, contenu HTML)
  - Aperçu live à droite (rendu via flutter_html)
- Création / modification / suppression

### Référentiel d'émotions

- Vue en cards groupées par catégorie (couleur d'identification)
- Création / édition de catégorie : nom, couleur HEX, icône Material, ordre
- Ajout / suppression d'émotions niveau 2 dans chaque catégorie
- Wrap responsive : les cartes se réorganisent selon la largeur disponible

### Exercices de respiration

- Cards avec code court (748, 55, 46…), libellé, statut
- 3 pills affichant inspi/pause/expi en secondes
- Édition complète avec validation : inspi ≥ 1s, pause ≥ 0s, expi ≥ 1s

## Sécurité

- Le router redirige automatiquement vers `/login` si l'utilisateur n'est pas administrateur
- Token séparé du mobile (`cesizen_admin_token`) pour permettre une cohabitation sur le même navigateur
- Toutes les requêtes admin passent par le middleware `role:admin` côté API
- Restauration de session vérifiée à l'ouverture (appel `/auth/me` puis contrôle du rôle)

## Build production

```bash
# Build optimisé pour serveur web
flutter build web --release --base-href "/admin/"

# Sortie dans build/web/
```

À déployer derrière un reverse-proxy (nginx, Apache) configuré pour rediriger toutes les routes vers `index.html` (mode SPA).

## Captures d'écran

| Vue | Description |
|---|---|
| Login | Split layout avec illustration pastel à gauche et formulaire à droite |
| Dashboard | 6 KPI cards + barre d'état de plateforme |
| Utilisateurs | DataTable paginée + dialog CRUD modal |
| Pages | Liste tabulaire + éditeur split avec aperçu live |
| Émotions | Cards par catégorie avec chips d'émotions |
| Respiration | Cards par exercice avec pills inspi/pause/expi |
