# Sécurité — CESIZen

Corrections apportées à la suite de l'analyse de sécurité du projet.

Sources : analyse statique **SonarQube Cloud** déclenchée par l'intégration
continue, audit des dépendances **`composer audit`**, et revue manuelle des
contrôles d'accès au regard du **top 10 OWASP**.

Chaque ligne correspond à un commit unique, cliquable dans l'historique.

---

## Corrections

| # | Faille | Origine | Où | Correction | Commit |
|---|---|---|---|---|---|
| 1 | Contrôle d'accès masqué par une erreur serveur, et divulgation de la trace d'exécution | Revue manuelle · OWASP A01, A05 | `bootstrap/app.php` | Redirection anonyme désactivée et rendu JSON forcé sur `api/*` : les routes protégées répondent 401 au lieu de 500 | `10272b6` |
| 2 | Absence totale de limitation de débit — force brute possible sur `/auth/login` | Revue manuelle · OWASP A07 | `AppServiceProvider.php`, `routes/api.php` | Limiteur `auth` à 5 requêtes/min/IP sur les routes d'authentification, limiteur `api` à 60/min sur le reste | `180a193` |
| 3 | CORS totalement ouvert : `allowed_origins`, `allowed_methods` et `allowed_headers` à `*` | SonarQube · OWASP A05 | `config/cors.php` | Origines restreintes au back-office, méthodes et en-têtes énumérés | `93f91e2` |
| 4 | Identifiants en dur : compte administrateur créé avec le mot de passe `password` | `composer audit` S2068 · OWASP A07 | `database/seeders/AdminUserSeeder.php` | Mots de passe lus dans l'environnement, sans valeur de repli ; aléatoire affiché à défaut | `21501b5` |
| 5 | Politique de mot de passe insuffisante (`min:8` seul), dupliquée à six endroits | Revue manuelle · OWASP A07 | `AppServiceProvider.php` + 6 points d'entrée | `Password::defaults()` : 12 caractères, majuscule et minuscule, chiffre, symbole | `a038d3c` |
| 6 | 33 vulnérabilités connues dans les dépendances, dont 8 de sévérité haute | `composer audit` · OWASP A06 | `composer.lock` | Mise à jour dans les bornes de `composer.json` : 30 avis levés | `19c115f` |
| 7 | 3 avis résiduels non corrigeables sans montée de version majeure | `composer audit` · OWASP A06 | `composer.json` | Déclarés dans `config.audit.ignore` avec justification ; l'audit reste bloquant pour toute nouvelle vulnérabilité | `ab6d56d` |

Deux corrections supplémentaires proviennent de la conteneurisation
(commit `9660bec`) : les identifiants MariaDB, jusque-là écrits en clair
dans le fichier `docker-compose.yml` versionné, passent par des variables
d'environnement ; et le service phpMyAdmin, qui publiait une console
d'administration de la base sur le port 8081, est retiré de la stack.

---

## Justification des valeurs retenues

### Pourquoi 5 tentatives par minute, et pas 10 ?

La limite doit gêner l'attaquant sans gêner l'utilisateur. Un utilisateur
qui se trompe de mot de passe réessaie deux ou trois fois, puis passe par
« mot de passe oublié » : 5 laisse une marge confortable et ne produit
aucun faux positif à l'usage.

Côté attaquant, 5 par minute plafonne à 7 200 essais par jour. Face à la
politique de mot de passe retenue — 12 caractères sur un alphabet d'environ
90 — l'espace de recherche dépasse 10²³ : la force brute en ligne devient
sans objet. Passer à 10 doublerait ce plafond sans rien changer à cette
conclusion, tout en doublant ce qu'un attaquant obtient gratuitement.

Le comptage porte sur l'adresse IP seule. C'est une limite assumée : un
attaquant disposant de plusieurs adresses la contourne partiellement. Une
clé combinant l'IP et l'email visé aurait protégé un compte donné contre
une rotation d'adresses ; le choix a été fait de garder la règle simple et
lisible, l'exposition réelle du projet ne justifiant pas cette complexité.

### Pourquoi 12 caractères, et pourquoi des règles de composition ?

Le passage de 8 à 12 est le facteur qui compte : chaque caractère
supplémentaire multiplie l'espace de recherche par la taille de l'alphabet,
soit environ 90 ici. Les règles de composition ajoutent surtout une
garantie sur cet alphabet — sans elles, rien n'empêche 12 minuscules.

Il faut savoir que l'ANSSI et le NIST recommandent aujourd'hui de
privilégier la longueur et de ne plus imposer de règles de composition, qui
poussent les utilisateurs vers des motifs prévisibles du type `Password1!`.
Le choix inverse est assumé ici : sur une application manipulant des
données de santé, la garantie explicite sur l'alphabet a été jugée
préférable, et la contrainte reste tenable pour l'utilisateur.

La règle est déclarée une seule fois, dans `AppServiceProvider`. Elle
existait auparavant en six exemplaires — ce qui garantissait qu'un
durcissement en oublierait au moins un.

### Pourquoi ne pas monter en Laravel 12 ?

Les 3 avis résiduels ne sont corrigés qu'à partir de Laravel 12.60.0 et
12.61.1. Le projet déclare `^11.0` : ils sont inatteignables sans montée de
version majeure, arbitrée hors du délai de la soutenance.

Plutôt que de rendre `composer audit` non bloquant — ce qui reviendrait à
ne plus rien détecter du tout — les trois identifiants sont déclarés
individuellement dans `config.audit.ignore`, avec la raison de chaque
dérogation. L'audit continue donc de faire échouer l'intégration continue
si une nouvelle vulnérabilité apparaît.

Sur l'un des trois, `PKSA-m5cs-t1y6-qpcs` (confusion de chemin sur les URL
signées temporaires), la dérogation ne repose pas sur un arbitrage de
délai : le projet n'expose aucune URL signée. Ni `Route::signed` ni
`URL::temporarySignedRoute` n'apparaissent dans `app/` ou `routes/`, le
code vulnérable n'est donc jamais atteint.

### Pourquoi Sanctum plutôt que JWT ?

L'authentification repose sur les jetons d'accès personnels de Sanctum,
transmis dans l'en-tête `Authorization: Bearer`.

Un jeton Sanctum est **opaque** et stocké **haché** en base : le supprimer
le révoque immédiatement. Un JWT est auto-porteur et signé — il n'est pas
consulté en base à la vérification, ce qui le rend plus économe et plus
adapté à une architecture distribuée, mais **irrévocable avant expiration**
sans mettre en place une liste de révocation, laquelle rétablit justement
l'accès à un état partagé qu'on cherchait à éviter.

Sur une application qui suit les émotions de ses utilisateurs, donc des
données de santé, pouvoir couper l'accès d'un jeton compromis sans attendre
son expiration a primé sur le gain de performance. L'architecture est par
ailleurs monolithique : l'argument de scalabilité du JWT n'y trouve pas
d'application.

Le contrôleur de connexion révoque les jetons existants à chaque connexion
(`$user->tokens()->delete()`), ce qui limite le projet à une session active
par utilisateur.

---

## Ce qui était déjà correct

Ces points ont été vérifiés pendant la revue et n'ont pas nécessité de
correction. Ils sont mentionnés parce qu'ils constituent l'essentiel du
contrôle d'accès.

- **Pas de référence directe non sécurisée sur le journal d'émotions.**
  Toutes les lectures passent par `findByIdForUser($id, $userId)` et
  `listForUser($userId)` : le filtre sur `id_user` est appliqué dans la
  requête SQL, pas après coup. Un utilisateur ne peut pas atteindre une
  entrée qui ne lui appartient pas en devinant son identifiant.
- **Pas d'élévation de privilège à l'inscription.** `RegisterRequest` ne
  valide pas `id_role`, et `UserService::registerUser()` force le rôle
  côté serveur. Un champ `id_role` envoyé dans la requête est ignoré.
- **Pas de modification de rôle depuis le profil.**
  `UserService::updateProfile()` retire explicitement `id_role` et
  `id_user_state` des données avant enregistrement.
- **Pas d'énumération d'utilisateurs à la connexion.** Un email inconnu et
  un mot de passe incorrect renvoient le même message et le même code.
- **Mots de passe hachés.** Le modèle `User` déclare
  `'password' => 'hashed'` et masque `password` et `remember_token` en
  sérialisation.

---

## Vérification

L'intégration continue exécute à chaque *pull request* et à chaque poussée
sur `main` et `develop` :

- la suite de tests contre un service **MariaDB**, le moteur de production ;
- **`composer audit`**, bloquant ;
- l'analyse **SonarQube Cloud** avec remontée de la couverture ;
- la construction des images Docker de production.

Les corrections 1, 2, 4 et 5 sont couvertes par des tests automatisés :
réponse 401 sans en-tête `Accept`, réponse 429 à la sixième tentative de
connexion avec en-tête `Retry-After`, refus des mots de passe non conformes
sur les **six** points d'entrée sans création de compte, et vérification
que le seeder ne crée plus le compte d'administration avec un mot de passe
prévisible. La suite est passée de 14 à 32 tests.

### Sur les deux chiffres de couverture

Le tableau de bord affiche deux valeurs très différentes : environ **21 %
de couverture globale**, et **100 % sur le code nouveau**. Les deux sont
exactes et ne mesurent pas la même chose.

Le projet a été développé avant que les tests ne deviennent une priorité :
la majeure partie du code existant n'est pas couverte, et le rattraper
n'entrait pas dans le périmètre de cette campagne de sécurité. Le quality
gate applique en revanche le principe *clean as you code* recommandé par
SonarQube — il n'exige rien du code ancien, mais impose 80 % de couverture
sur toute ligne ajoutée ou modifiée. La dette existante est donc gelée, et
tout nouvel apport arrive testé.

Ce seuil a d'ailleurs fait échouer la première version de ces corrections,
et à juste titre : `SECURITE.md` affirmait que la politique de mot de passe
s'appliquait aux six points d'entrée, alors qu'un seul était testé. Les
cinq autres l'ont été à la suite de ce refus.

La mesure porte sur `app/`. `config/`, `database/` et `routes/` en sont
écartés — non pour améliorer le chiffre, mais parce que l'instrumentation
pcov n'y rapporte aucune ligne exécutée même lorsqu'ils le sont : les
seeders appelés par chaque test y figuraient à 0 %. Ces répertoires restent
analysés par SonarQube pour la recherche de défauts ; seule leur mesure de
couverture est écartée.
