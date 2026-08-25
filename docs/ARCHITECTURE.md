# CESI Zen — Architecture & fonctionnement

Document pédagogique pour comprendre **exactement** ce qui se passe quand
l'utilisateur interagit avec l'application, du clic jusqu'à la base de
données et retour.

---

## Table des matières

1. [Vue d'ensemble](#1-vue-densemble)
2. [Anatomie de l'API Laravel](#2-anatomie-de-lapi-laravel)
3. [Anatomie du client mobile Flutter](#3-anatomie-du-client-mobile-flutter)
4. [Flux complet : afficher l'accueil](#4-flux-complet--afficher-lécran-daccueil)
5. [Flux complet : se connecter](#5-flux-complet--se-connecter)
6. [Flux complet : saisir une émotion](#6-flux-complet--saisir-une-émotion)
7. [MLD — Modèle Logique des Données](#7-mld--modèle-logique-des-données)

---

## 1. Vue d'ensemble

Le projet CESI Zen est composé de **trois sous-applications** qui
communiquent uniquement par HTTP+JSON :

```
┌──────────────────────┐                         ┌──────────────────────┐
│  App MOBILE Flutter  │ ◄────── HTTP/JSON ─────►│                      │
│  (iOS / Android)     │       Bearer token      │   API REST Laravel   │
│                      │                         │   (PHP 8.4)          │
│  Utilisateur final   │                         │                      │
└──────────────────────┘                         │   MVC + Repository   │
                                                 │   + Sanctum (auth)   │
┌──────────────────────┐                         │                      │
│  BACKOFFICE Flutter  │ ◄────── HTTP/JSON ─────►│                      │
│  Web (Chrome)        │       Bearer token      │                      │
│                      │                         │                      │
│  Administrateurs     │                         └──────────┬───────────┘
└──────────────────────┘                                    │
                                                            │
                                                            ▼
                                                 ┌──────────────────────┐
                                                 │   MariaDB 11         │
                                                 │   (Docker)           │
                                                 └──────────────────────┘
```

**Pourquoi cette séparation ?**

- **Une seule source de vérité** (l'API) — si la règle métier change
  (« cooldown 5 min »), on la modifie à un seul endroit.
- **Le mobile et le web partagent le même backend** — pas de doublons.
- **Le frontend ne connaît pas la base** — il fait des requêtes HTTP, le
  serveur s'occupe de SQL.

**Ports utilisés** (dev) :
- API : `localhost:8001`
- Base de données : `localhost:3307` (client SQL local ; aucune interface
  d'administration web n'est exposée par la stack)
- Back-office web : `localhost:3000`
- Mobile sur navigateur : `localhost:3001`
- Mobile natif : se connecte à `localhost:8001` (iOS) ou `10.0.2.2:8001`
  (émulateur Android)

Les ports `3000` et `3001` sont imposés par la politique CORS de l'API,
qui les déclare comme seules origines autorisées.

---

## 2. Anatomie de l'API Laravel

L'API suit un **pattern MVC + Repository** (5 couches) :

```
┌───────────────────────────────────────────────────────────────────┐
│  REQUÊTE HTTP entrante                                            │
│  ex : POST /api/journal  Authorization: Bearer XXX                │
└───────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌───────────────────────────────────────────────────────────────────┐
│  1. routes/api.php                                                │
│     Route::post('/journal', [EmotionJournalController::class, 'store']);
│     Avec middleware('auth:sanctum') → vérifie le token            │
└───────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌───────────────────────────────────────────────────────────────────┐
│  2. FormRequest (JournalEntryStoreRequest)                        │
│     Validation : id_emotion required + exists, note max:2000…     │
│     Si KO → 422 Unprocessable Entity (auto)                       │
└───────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌───────────────────────────────────────────────────────────────────┐
│  3. Controller (EmotionJournalController::store)                  │
│     Reçoit la requête validée + l'user authentifié.               │
│     Délègue au Service. Ne contient PAS de logique métier.        │
└───────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌───────────────────────────────────────────────────────────────────┐
│  4. Service (EmotionJournalService::create)                       │
│     Logique métier ici : check cooldown 5 min, calcul felt_at…    │
│     Lance TooManyRequestsHttpException → 429 si cooldown.         │
└───────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌───────────────────────────────────────────────────────────────────┐
│  5. Repository (EmotionJournalRepository::create)                 │
│     Accès données. Une seule méthode : Eloquent → SQL.            │
│     Aucune logique métier ici.                                    │
└───────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌───────────────────────────────────────────────────────────────────┐
│  6. Model Eloquent (EmotionJournalEntry)                          │
│     Représente la table emotion_journal_entries.                  │
│     EmotionJournalEntry::create($data) → INSERT INTO …            │
└───────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌───────────────────────────────────────────────────────────────────┐
│  7. MariaDB                                                       │
│     Persiste la ligne et retourne l'id.                           │
└───────────────────────────────────────────────────────────────────┘

Et le retour suit le chemin inverse :
DB → Model → Repository → Service → Controller
→ JournalEntryResource (transforme en JSON sortie)
→ Response HTTP 201 { id, id_user, id_emotion, ... }
```

### Pourquoi tant de couches ?

| Couche | Responsabilité | Si on la supprime ? |
|---|---|---|
| Route | Routage URL → contrôleur | Impossible (Laravel) |
| FormRequest | Validation des entrées | Le contrôleur deviendrait sale |
| Controller | Orchestration HTTP↔métier | Difficile à tester |
| **Service** | **Règles métier** | Logique éparpillée dans les contrôleurs |
| Repository | Accès données isolé | Couplage fort à Eloquent → tests difficiles |
| Model | Mapping ORM table↔objet | On écrirait du SQL brut partout |
| Resource | Format JSON sortant | On exposerait des champs internes |

### Exemple concret : cooldown 5 min

Le **service** centralise la règle métier — tu peux le lire ici :

`api/src/app/Services/EmotionJournalService.php` :

```php
public function create(int $userId, array $data): EmotionJournalEntry
{
    // Règle métier #1 : cooldown 5 min
    $last = $this->repository->lastEntryFor($userId);
    if ($last && $last->created_at) {
        $elapsed = (int) floor($last->created_at->diffInSeconds(now(), absolute: true));
        if ($elapsed < self::COOLDOWN_SECONDS) {
            $retryAfter = self::COOLDOWN_SECONDS - $elapsed;
            throw new TooManyRequestsHttpException(
                retryAfter: $retryAfter,
                message: "Patientez encore X min Y s avant une nouvelle saisie.",
            );
        }
    }

    // Règle métier #2 : felt_at distinct de created_at
    $feltAt = isset($data['felt_at']) ? Carbon::parse($data['felt_at']) : now();
    // entry_date dérivée de felt_at pour les rapports par jour
    $entryDate = $feltAt->toDateString();

    return $this->repository->create([
        'id_user' => $userId,
        'id_emotion' => $data['id_emotion'],
        'felt_at' => $feltAt,
        'entry_date' => $entryDate,
        'note' => $data['note'] ?? null,
    ]);
}
```

Le **contrôleur** ne fait que déléguer :

```php
public function store(JournalEntryStoreRequest $request): JsonResponse
{
    $entry = $this->service->create(
        $request->user()->id_user,
        $request->validated(),
    );
    return response()->json(new JournalEntryResource($entry), 201);
}
```

---

## 3. Anatomie du client mobile Flutter

Le mobile suit un **pattern Riverpod** (équivalent MVVM) :

```
┌───────────────────────────────────────────────────────────────────┐
│  UI : un Widget (ex: HomePage, QuickEmotionPage)                  │
│  ─────────────────────────────────────────                        │
│  C'est ce que l'utilisateur voit. Un widget Flutter qui peut      │
│  appeler ref.watch(unProvider) pour lire des données réactives.   │
└───────────────────────────────────────────────────────────────────┘
                              │  ref.watch / ref.read
                              ▼
┌───────────────────────────────────────────────────────────────────┐
│  Provider (Riverpod) : ex top24hProvider                          │
│  ─────────────────────────────────────                            │
│  Une "boîte" qui contient de la donnée + sait comment la (re)     │
│  fabriquer. Si la donnée change, tous les widgets qui watch       │
│  rebuild automatiquement.                                         │
└───────────────────────────────────────────────────────────────────┘
                              │  appelle
                              ▼
┌───────────────────────────────────────────────────────────────────┐
│  Service : ex JournalService.top24h()                             │
│  ──────────────────────────────                                   │
│  Wrapper typé autour de Dio. Convertit une méthode Dart en        │
│  requête HTTP + parsing JSON. Pas de logique métier ici.          │
└───────────────────────────────────────────────────────────────────┘
                              │  dio.get/post/put
                              ▼
┌───────────────────────────────────────────────────────────────────┐
│  Dio (client HTTP) + AuthInterceptor                              │
│  ──────────────────────────────────                               │
│  Dio fait la requête HTTP. Avant l'envoi, l'AuthInterceptor       │
│  lit ref.read(authProvider).token et ajoute "Authorization:       │
│  Bearer XXX" au header.                                           │
└───────────────────────────────────────────────────────────────────┘
                              │  HTTP/JSON
                              ▼
                       ┌─────────────┐
                       │     API     │
                       └─────────────┘
                              │
                              ▼  HTTP réponse JSON
┌───────────────────────────────────────────────────────────────────┐
│  Model.fromJson()                                                 │
│  ─────────────                                                    │
│  Convertit le JSON brut en objet Dart typé (ex: JournalEntry).    │
└───────────────────────────────────────────────────────────────────┘
                              │  retour
                              ▼
                       Le Provider notifie
                              │
                              ▼
                       L'UI rebuild (rebuild = re-render)
```

### Pourquoi Riverpod (et pas du setState partout) ?

- **Réactivité globale** : un changement dans un provider rebuild
  automatiquement tous les widgets qui le `watch` — pas besoin de
  remonter manuellement les callbacks.
- **Injection de dépendances** : chaque provider peut lire d'autres
  providers, ce qui fait que l'`AuthInterceptor` accède au token
  sans qu'on ait à le passer en paramètre.
- **Testabilité** : on peut override n'importe quel provider en test.

### Cycle de vie d'un provider

```
État 0  ────────► L'UI ne le watch pas       (pas instancié)
                     │
                     ▼ premier ref.watch
État 1  ────────► AsyncValue.loading         (UI affiche spinner)
                     │
                     ▼ HTTP réussit
État 2  ────────► AsyncValue.data(WindowReport(...))   (UI affiche les chiffres)
                     │
                     ▼ ref.invalidate(provider)
                     │
                     ▼ refetch
État 3  ────────► AsyncValue.loading         (UI re-affiche spinner)
                     │
                     ▼ HTTP échoue (ex: 401)
État 4  ────────► AsyncValue.error           (UI affiche ErrorView)
```

---

## 4. Flux complet : afficher l'écran d'accueil

Tu lances l'app (en visiteur, déjà sur `/`).

### Étape par étape

**1. `main.dart` s'exécute**

```dart
void main() {
  runApp(const ProviderScope(child: CesiApp()));
}
```

`ProviderScope` est le conteneur Riverpod racine. Sans lui, aucun
provider ne fonctionne.

**2. `CesiApp` construit le `MaterialApp.router`**

Il lit `routerProvider` qui retourne un `GoRouter` configuré avec
toutes les routes.

**3. Le router évalue le `redirect`** dans
`mobile/lib/core/router/app_router.dart` :

```dart
String? _guard(BuildContext context, GoRouterState state) {
  final auth = _ref.read(authProvider);
  final loc = state.uri.path;

  if (auth.isInitializing) return null;  // ← état initial, on attend

  final isVisitorAllowed = loc == '/' ||
      loc.startsWith('/infos') ||
      loc == '/quick-emotion';

  if (!auth.isAuthenticated) {
    if (isPublicRoute || isVisitorAllowed) return null;
    return '/login';  // ← profil/journal verrouillés
  }
  return null;
}
```

`/` est autorisé en visiteur → on continue.

**4. `MainScaffold` construit la BottomNavigationBar + l'enfant `HomePage`**

**5. `HomePage.build` s'exécute**

```dart
final auth = ref.watch(authProvider);
...
body: auth.isAuthenticated ? const _AuthenticatedHome() : const _VisitorHome(),
```

`ref.watch(authProvider)` dit : « je veux la valeur courante, et si
elle change, rebuild-moi ».

**6. `_VisitorHome.build` s'exécute**

```dart
final transient = ref.watch(transientEmotionProvider);
```

`transientEmotionProvider` est un `StateProvider<TransientEmotion?>`
qui contient `null` par défaut → on affiche le `+`.

**7. L'utilisateur tape sur l'emoji `+`**

```dart
_CenterEmoji(
  emotion: CesiEmotion.plus,
  onTap: () => context.push('/quick-emotion'),  // ← clic !
  ...
)
```

`context.push('/quick-emotion')` empile la page de saisie au-dessus
de l'accueil. (Différent de `context.go('/path')` qui remplace.)

**8. `QuickEmotionPage` se construit**

```dart
final categoriesAsync = ref.watch(emotionCategoriesProvider);
```

C'est le moment magique : Riverpod voit qu'on demande
`emotionCategoriesProvider` pour la **première fois**. Il l'instancie :

```dart
final emotionCategoriesProvider = FutureProvider<List<EmotionCategory>>((ref) async {
  return ref.read(emotionServiceProvider).listCategories();
});
```

→ qui appelle `EmotionService.listCategories()` :

```dart
Future<List<EmotionCategory>> listCategories() async {
  final res = await _dio.get('/emotion-categories');
  return (res.data as List)
      .map((e) => EmotionCategory.fromJson(e as Map<String, dynamic>))
      .toList();
}
```

**9. Dio prépare la requête**

`_dio.get('/emotion-categories')` → Dio construit l'URL :
`http://localhost:8001/api/emotion-categories`.

**10. L'AuthInterceptor intervient**

```dart
void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
  final token = getToken();  // ref.read(authProvider).token
  if (token != null && token.isNotEmpty) {
    options.headers['Authorization'] = 'Bearer $token';
  }
  handler.next(options);
}
```

Pour un visiteur, `token` est `null` → aucun header Bearer ajouté.

**11. La requête HTTP part**

```
GET /api/emotion-categories HTTP/1.1
Host: localhost:8001
Accept: application/json
```

**12. Côté Laravel**

```php
// routes/api.php
Route::get('/emotion-categories', [EmotionCategoryController::class, 'index']);
//      ↑ route PUBLIQUE (pas dans le groupe auth:sanctum)
```

**13. Le contrôleur s'exécute**

```php
public function index(): JsonResponse
{
    $categories = EmotionCategory::with('emotions')
        ->where('is_active', true)
        ->orderBy('sort_order')
        ->get();
    return response()->json(EmotionCategoryResource::collection($categories));
}
```

`with('emotions')` = eager loading : on récupère les catégories ET
toutes leurs émotions de niveau 2 dans **2 requêtes SQL** au lieu de
1+N (problème N+1).

**14. Eloquent exécute** :

```sql
SELECT * FROM emotion_categories WHERE is_active = 1 ORDER BY sort_order;
SELECT * FROM emotions WHERE id_emotion_category IN (1,2,3,4,5,6);
```

**15. Le `EmotionCategoryResource` transforme en JSON**

```php
return [
    'id_emotion_category' => $this->id_emotion_category,
    'name' => $this->name,
    'feeling_label' => $this->feeling_label,
    'color_hex' => $this->color_hex,
    ...
    'emotions' => $this->whenLoaded('emotions', fn() => ...),
];
```

**16. La réponse HTTP part**

```json
HTTP/1.1 200 OK
Content-Type: application/json

[
  {
    "id_emotion_category": 1,
    "name": "Joie",
    "feeling_label": "joyeux",
    "color_hex": "#B0E0E6",
    "emotions": [
      {"id_emotion": 1, "name": "Fierté", "feeling_label": "fier"},
      ...
    ]
  },
  ...
]
```

**17. Mobile : Dio parse en `Response.data`** (qui est une `List<dynamic>`).

**18. `EmotionService` mappe** chaque entrée via `EmotionCategory.fromJson(…)`
qui produit des objets Dart typés.

**19. Le `FutureProvider` résout** :
`categoriesAsync` passe de `AsyncValue.loading` à `AsyncValue.data([…])`.

**20. Riverpod notifie** tous les widgets qui watchent → rebuild
automatique.

**21. `QuickEmotionPage` rebuild** et affiche les 6 cartes.

Voilà — un clic → 21 étapes traçables.

---

## 5. Flux complet : se connecter

```
┌─────────────────────────────────────────────────────────────────┐
│ MOBILE                                                          │
├─────────────────────────────────────────────────────────────────┤
│ 1. LoginPage : utilisateur saisit email + mdp, tape "Connexion".│
│                                                                 │
│ 2. _submit() :                                                  │
│    final result = await ref.read(authServiceProvider).login(   │
│      email: ..., password: ...,                                 │
│    );                                                           │
│                                                                 │
│ 3. AuthService.login() fait POST /api/auth/login                │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼ HTTP POST
                {
                  "email": "demo@cesizen.fr",
                  "password": "password"
                }
                              │
┌─────────────────────────────────────────────────────────────────┐
│ API LARAVEL                                                     │
├─────────────────────────────────────────────────────────────────┤
│ 4. Route::post('/auth/login', [AuthController::class, 'login']) │
│                                                                 │
│ 5. AuthController::login                                        │
│    - Valide via LoginRequest (email + password requis)          │
│    - Délègue à AuthService                                      │
│                                                                 │
│ 6. AuthService::attemptLogin($email, $password)                 │
│    - $user = UserRepository->findByEmail($email)                │
│    - Hash::check($password, $user->password)                    │
│    - Si user désactivé → 403                                    │
│    - $token = $user->createToken('mobile')->plainTextToken      │
│      ← Sanctum génère un token et l'écrit dans                  │
│        personal_access_tokens                                   │
│                                                                 │
│ 7. Retourne JSON                                                │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼ HTTP 200
                {
                  "token": "1|XXXXX...",
                  "user": {
                    "id_user": 2,
                    "email": "demo@cesizen.fr",
                    "first_name": "Demo",
                    "role": {"name": "user"},
                    "user_state": {"name": "active"}
                  }
                }
                              │
┌─────────────────────────────────────────────────────────────────┐
│ MOBILE — retour                                                 │
├─────────────────────────────────────────────────────────────────┤
│ 8. result = AuthResult(token, user)                             │
│                                                                 │
│ 9. await ref.read(authProvider.notifier).login(token, user)     │
│    - await prefs.setString(tokenKey, token)                     │
│      ↑ persistance (SharedPreferences = localStorage en web)    │
│    - state = AuthState(token: ..., user: ...)                   │
│      ↑ tous les widgets qui watch(authProvider) rebuild         │
│                                                                 │
│ 10. invalidateSessionData(ref)                                  │
│     ref.invalidate(infoPagesProvider, top24hProvider, …)        │
│     ↑ tous les providers data sont rechargés                    │
│                                                                 │
│ 11. context.go('/')                                             │
│     ↑ remplace la stack par /                                   │
│                                                                 │
│ 12. _guard du router se réévalue :                              │
│     auth.isAuthenticated = true → accès à /                     │
│                                                                 │
│ 13. HomePage construit _AuthenticatedHome                       │
│     - ref.watch(lastJournalEntryProvider) → GET /journal        │
│     - ref.watch(top24hProvider) → GET /journal/top-24h          │
│     - Cette fois l'AuthInterceptor attache le Bearer token      │
│       (lecture synchrone depuis state Riverpod)                 │
└─────────────────────────────────────────────────────────────────┘
```

### Pourquoi le token est lu depuis le state, pas SharedPreferences ?

Sur Flutter Web, `prefs.setString(…)` et `prefs.getString(…)` ont un
micro-délai (le navigateur écrit dans `localStorage` qui n'est pas
toujours immédiatement re-lisible). Avant le fix, la première requête
après login pouvait partir sans Bearer → 401 → écran d'erreur.

Le state Riverpod est **synchrone** : dès que `state = AuthState(…)`
est exécuté, `ref.read(authProvider).token` retourne le nouveau token.
Plus de race condition.

---

## 6. Flux complet : saisir une émotion

```
QuickEmotionPage : grille des 6 catégories visibles
              │
              ▼
   User tape sur "Colère"
              │
              ▼ _onCategoryTapped(cat)
        setState(() {
          _selectedCategory = cat;
          _selectedEmotion = null;
        });
              │
              ▼ Scrollable.ensureVisible(_level2Key)
   Scroll auto vers les chips niveau 2
              │
              ▼
   Affichage des chips Frustration / Irritation / Rage / Hostilité…
              │
              ▼
   User tape sur "Hostilité"
              │
              ▼
   setState(() { _selectedEmotion = emo; });
              │
              ▼
   User tape "À l'instant" (chip durée)
              │
              ▼
   setState(() { _minutesAgo = 0; });
              │
              ▼
   User tape "Enregistrer dans mon journal"
              │
              ▼
   _save(isAuthed=true)
              │
              ▼
   final feltAt = DateTime.now();  // (minutesAgo=0)
              │
              ▼
   await journalService.create(
     emotionId: emo.id,           // 16 (Hostilité)
     feltAt: feltAt,
     note: noteCtrl.text.trim().isEmpty ? null : noteCtrl.text.trim(),
   );
              │
              ▼ HTTP POST /api/journal
              │   { id_emotion: 16, felt_at: "2026-05-10T15:42:00Z", ... }
              │
        ┌─────┴─────┐
        ▼           ▼
┌─────────────┐  ┌────────────────────────────────────────┐
│  Réponse    │  │ Si cooldown 5 min non respecté :       │
│  201 Created│  │   API renvoie 429 + Retry-After: 240   │
│  { id: 42…} │  │   Dio convertit en DioException        │
└─────────────┘  │   JournalService.create détecte 429,   │
        │        │   lance EmotionCooldownException      │
        │        │     (qui contient message + retryAfter)│
        │        │                                        │
        │        │   QuickEmotionPage catch → snackbar    │
        │        │   "Patientez encore 4 min 00 s…"       │
        │        └────────────────────────────────────────┘
        │
        ▼
   invalidateJournalViews(ref)  // top24h, lastEntry, journal list
              │
              ▼
   Snackbar succès + context.go('/')
              │
              ▼
   HomePage rebuild → lastEntry et top24h refetchent
              │
              ▼
   Affichage de l'emoji + "Vous vous sentez hostile"
```

---

## 7. MLD — Modèle Logique des Données

### Schéma relationnel (avec clés primaires en **gras**, étrangères en *italique*)

```
┌────────────────────────────┐        ┌────────────────────────────┐
│ roles                      │        │ user_states                │
├────────────────────────────┤        ├────────────────────────────┤
│ id_role         BIGINT PK  │        │ id_user_state   BIGINT PK  │
│ name            VARCHAR(50)│        │ name            VARCHAR(50)│
│ label           VARCHAR(100)│       │ label           VARCHAR(100)│
│ created_at      DATETIME   │        │ created_at      DATETIME   │
│ updated_at      DATETIME   │        │ updated_at      DATETIME   │
└──────────┬─────────────────┘        └──────────────┬─────────────┘
           │ 1                                       │ 1
           │                                         │
           │ N                                       │ N
┌──────────▼─────────────────────────────────────────▼─────────────┐
│ users                                                            │
├──────────────────────────────────────────────────────────────────┤
│ id_user            BIGINT PK                                     │
│ first_name         VARCHAR(50)                                   │
│ last_name          VARCHAR(50)                                   │
│ email              VARCHAR(255) UNIQUE                           │
│ password           VARCHAR(255)            -- Hash bcrypt        │
│ city               VARCHAR(100) NULL                             │
│ birth_date         DATE NULL                                     │
│ id_role            BIGINT FK → roles.id_role                     │
│ id_user_state      BIGINT FK → user_states.id_user_state         │
│ created_at         DATETIME                                      │
│ updated_at         DATETIME NULL                                 │
│ deleted_at         DATETIME NULL     -- soft delete (RGPD)       │
└──────────┬───────────────────────────────────────────────────────┘
           │ 1
           │
           │ N
           ▼
┌──────────────────────────────────────────────────────────────────┐
│ emotion_journal_entries                                          │
├──────────────────────────────────────────────────────────────────┤
│ id_journal_entry   BIGINT PK                                     │
│ id_user            BIGINT FK → users.id_user                     │
│ id_emotion         BIGINT FK → emotions.id_emotion               │
│ entry_date         DATE          -- jour du ressenti             │
│ felt_at            DATETIME NULL -- instant du ressenti          │
│ note               TEXT NULL                                     │
│ created_at         DATETIME      -- moment de la saisie (cooldown)│
│ updated_at         DATETIME NULL                                 │
└──────────────────────────────────────────┬───────────────────────┘
                                           │ N
                                           │
                                           │ 1
                                           ▼
┌──────────────────────────────────────────────────────────────────┐
│ emotions                                                         │
├──────────────────────────────────────────────────────────────────┤
│ id_emotion              BIGINT PK                                │
│ id_emotion_category     BIGINT FK → emotion_categories.id_emoti…│
│ name                    VARCHAR(50)         -- "Hostilité"       │
│ feeling_label           VARCHAR(80) NULL    -- "hostile"         │
│ is_active               BOOLEAN DEFAULT 1                        │
│ created_at              DATETIME                                 │
│ updated_at              DATETIME NULL                            │
│ UNIQUE (id_emotion_category, name)                               │
└──────────────────────────────────────────┬───────────────────────┘
                                           │ N
                                           │
                                           │ 1
                                           ▼
┌──────────────────────────────────────────────────────────────────┐
│ emotion_categories                                               │
├──────────────────────────────────────────────────────────────────┤
│ id_emotion_category     BIGINT PK                                │
│ name                    VARCHAR(50) UNIQUE -- "Colère"           │
│ feeling_label           VARCHAR(80) NULL   -- "en colère"        │
│ color_hex               VARCHAR(7)         -- "#F8C8D8"          │
│ icon                    VARCHAR(50) NULL   -- "sentiment_..."    │
│ sort_order              INTEGER DEFAULT 0                        │
│ is_active               BOOLEAN DEFAULT 1                        │
│ created_at              DATETIME                                 │
│ updated_at              DATETIME NULL                            │
└──────────────────────────────────────────────────────────────────┘

┌──────────────────────────────────────────────────────────────────┐
│ info_pages                                                       │
├──────────────────────────────────────────────────────────────────┤
│ id_info_page            BIGINT PK                                │
│ slug                    VARCHAR(100) UNIQUE                      │
│ title                   VARCHAR(200)                             │
│ menu_label              VARCHAR(100)                             │
│ content                 LONGTEXT (HTML)                          │
│ sort_order              INTEGER DEFAULT 0                        │
│ is_published            BOOLEAN DEFAULT 1                        │
│ created_at              DATETIME                                 │
│ updated_at              DATETIME NULL                            │
└──────────────────────────────────────────────────────────────────┘

┌──────────────────────────────────────────────────────────────────┐
│ personal_access_tokens   (table technique Laravel Sanctum)       │
├──────────────────────────────────────────────────────────────────┤
│ id                      BIGINT PK                                │
│ tokenable_id            BIGINT     -- = id_user                  │
│ tokenable_type          VARCHAR    -- = "App\\Models\\User"      │
│ name                    VARCHAR                                  │
│ token                   VARCHAR    -- SHA256 hash                │
│ abilities               TEXT                                     │
│ last_used_at            DATETIME                                 │
└──────────────────────────────────────────────────────────────────┘
```

### Cardinalités

| Relation | Cardinalité | Sens |
|---|---|---|
| users ⟷ roles | N : 1 | un utilisateur a un rôle, un rôle est partagé par N utilisateurs |
| users ⟷ user_states | N : 1 | idem (active / inactive / pending) |
| users ⟷ emotion_journal_entries | 1 : N | un user a plusieurs entrées de journal |
| emotion_journal_entries ⟷ emotions | N : 1 | une entrée référence une émotion |
| emotions ⟷ emotion_categories | N : 1 | **relation hiérarchique niveau 2 → niveau 1** |

### Données seedées (référentiel)

**roles** (2 lignes) :
| id | name | label |
|---|---|---|
| 1 | admin | Administrateur |
| 2 | user | Utilisateur |

**user_states** (3 lignes) : `active`, `inactive`, `pending`

**emotion_categories** (6 lignes — les 6 émotions de base du sujet officiel) :

| id | name | feeling_label | color_hex |
|---|---|---|---|
| 1 | Joie | joyeux | #B0E0E6 |
| 2 | Colère | en colère | #F8C8D8 |
| 3 | Peur | apeuré | #C9DAF8 |
| 4 | Tristesse | triste | #778899 |
| 5 | Surprise | surpris | #FFF2CC |
| 6 | Dégoût | dégoûté | #F0D9F5 |

**emotions** (35 lignes — émotions niveau 2 du sujet officiel) :

| Catégorie | Émotions niveau 2 (avec feeling_label) |
|---|---|
| Joie | Fierté/fier · Contentement/content · Enchantement/enchanté · Excitation/excité · Émerveillement/émerveillé · Gratitude/reconnaissant |
| Colère | Frustration/frustré · Irritation/irrité · Rage/enragé · Ressentiment/plein de ressentiment · Agacement/agacé · Hostilité/hostile |
| Peur | Inquiétude/inquiet · Anxiété/anxieux · Terreur/terrifié · Appréhension/plein d'appréhension · Panique/paniqué · Crainte/craintif |
| Tristesse | Chagrin/plein de chagrin · Mélancolie/mélancolique · Abattement/abattu · Désespoir/désespéré · Solitude/seul · Dépression/déprimé |
| Surprise | Étonnement/étonné · Stupéfaction/stupéfait · Sidération/sidéré · Incrédulité/incrédule · Confusion/confus |
| Dégoût | Répulsion/pris de répulsion · Déplaisir/mal à l'aise · Nausée/écœuré · Dédain/dédaigneux · Horreur/horrifié · Dégoût profond/profondément dégoûté |

**info_pages** (12 articles seedés sur la santé mentale).

### Contraintes notables

- **Soft delete** sur `users` : `deleted_at` permet de désactiver un
  compte sans perdre l'historique (RGPD : la donnée reste 30 jours
  pour conformité, puis purge programmée).
- **ON DELETE RESTRICT** sur `id_role` et `id_user_state` : on ne
  peut pas supprimer un rôle utilisé par des utilisateurs.
- **ON DELETE CASCADE** sur `emotion_categories → emotions` : supprimer
  une catégorie supprime ses émotions niveau 2.
- **ON DELETE RESTRICT** sur `emotions → emotion_journal_entries` :
  on ne peut pas supprimer une émotion qui est utilisée dans un
  journal (logique : on désactive plutôt avec `is_active = 0`).

### Index secondaires

| Table | Index | But |
|---|---|---|
| `users.email` | UNIQUE | unicité + recherche login rapide |
| `emotions(id_emotion_category, name)` | UNIQUE | pas de doublon dans une catégorie |
| `emotion_journal_entries(id_user, entry_date)` | INDEX | rapport par période |
| `emotion_journal_entries(id_user, felt_at)` | INDEX | top 24h, requête sur instant précis |

---

## Résumé en une phrase

> Chaque interaction utilisateur traverse :
> **Widget → Provider Riverpod → Service Dart → Dio (+ AuthInterceptor) → HTTP → Route Laravel → Controller → Service PHP → Repository → Eloquent → MariaDB**,
> et inversement pour le retour, avec **JSON Resource** côté API et **Model.fromJson** côté Dart pour traduire les données.
