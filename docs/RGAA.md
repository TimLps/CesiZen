# Conformité RGAA — note d'accessibilité

> Document interne — synthèse des choix d'accessibilité du projet CESI Zen.

CESI Zen vise une conformité **WCAG 2.1 niveau AA** (équivalent RGAA 4.1) sur ses
deux frontends (mobile Flutter, back-office Flutter Web).

## Contraste de couleurs (critère 1.4.3)

La charte graphique impose la couleur `#778899` (gris ardoise clair). Sur fond
clair (`#FFFFFF` ou `#F0F8FF`), son ratio de contraste est de **3.6:1**, en
dessous des **4.5:1** requis par AA pour le texte courant.

**Décision** : on conserve `#778899` pour les éléments graphiques (icônes,
illustrations, sourcils des emojis, traits décoratifs, titres ≥18 pt en gras
qui n'ont besoin que de 3.0:1) et on utilise une teinte plus foncée pour le
texte courant :

| Usage | Couleur | Ratio sur blanc | Niveau |
|---|---|---|---|
| Charte graphique (icônes, illustrations) | `#778899` | 3.6:1 | AA pour large/UI uniquement |
| Texte courant (`textPrimary`) | `#566069` | ~5.4:1 | **AA conforme** |
| Texte secondaire (`textSecondary`) | `#6B7680` | ~4.5:1 | AA conforme |
| Hints / captions (`textMuted`) | `#7A8590` | 3.8:1 | AA-large uniquement |

Centralisé dans `mobile/lib/core/theme/app_theme.dart` et
`backoffice/lib/core/theme/admin_theme.dart`.

## Cibles tactiles (critère 2.5.5)

Tous les éléments interactifs respectent **44 × 44 dp** minimum :
- `BottomNavigationBar` : 56 dp par défaut Material
- `IconButton` : 48 dp par défaut Material
- `FloatingActionButton` : 56 dp par défaut
- `ChoiceChip` (durée, niveau 2) : ≥ 32 dp + padding interne ≥ 12 dp horizontal,
  hauteur Material par défaut ≥ 32 dp ; cibles regroupées dans un Wrap espacé.

## Sémantique (critère 4.1.2)

- `CesiEmoji` : enveloppé dans un `ExcludeSemantics` quand utilisé comme illustration ;
  le widget parent fournit le label via `Semantics(label: …)`.
- Tous les boutons icon ont un `tooltip` (Material l'injecte dans la couche
  d'accessibilité OS).
- `FloatingActionButton` a un `tooltip` explicite.
- `Semantics(button: true, selected: …, label: …)` sur les cartes de catégorie
  d'émotion (saisie rapide).
- `BottomNavigationBarItem.label` toujours renseigné, donc lu par les TalkBack /
  VoiceOver.

## Hiérarchie visuelle (critères 1.3.1 / 1.3.2)

- Polices : Montserrat + tailles variables (titres ≥ 18 pt en gras, body 14 pt).
- Hiérarchie typographique cohérente (`headlineLarge`, `titleMedium`, etc.).
- Pas de couleur seule comme indicateur d'état : icônes + texte + couleur sont
  combinés (cf. cartes de catégorie sélectionnée → bordure 2 px **+** fond
  lavande **+** `Semantics.selected`).

## Navigation clavier (critères 2.1.1 / 2.4.7)

- `Focusable` Material par défaut sur `InkWell` / `IconButton` / `ChoiceChip`.
- Le focus est visible (anneau Material par défaut).
- Pas de piège clavier (tous les Dialog ont une croix ou un bouton "Annuler").

## Champs de formulaire (critère 3.3.2)

- Tous les `TextField` / `TextFormField` ont un `labelText` ou un `Semantics(label:)`.
- Les hints sont distincts du label, pas utilisés comme seul moyen d'identifier le champ.
- Les messages d'erreur Material sont annoncés automatiquement aux TalkBack/VoiceOver.

## Animations (critère 2.3.3 — réduction des animations)

- Aucune animation > 5 s n'est non interruptible.
- Le `RefreshIndicator` et les transitions de routes utilisent les durées
  Material par défaut (≤ 350 ms).
- Conformément au cahier des charges PRISM (3.3.2 « animations fluides »),
  les transitions sont volontairement douces et courtes pour ne pas générer
  de stress.

## Internationalisation

- Une seule langue : français (cf. CdC §2.4 — pas de localisation requise).
- Tous les textes sont en `lang="fr"` implicite via le `MaterialApp` localisé.

## Points d'amélioration identifiés (post-livraison)

- [ ] Audit complet avec **Accessibility Scanner** (Android) et **Accessibility
  Inspector** (iOS) sur l'app mobile une fois lancée.
- [ ] Lighthouse / axe-core sur le back-office Web.
- [ ] Tests utilisateurs avec lecteur d'écran (TalkBack + VoiceOver + NVDA Web).
- [ ] Mode sombre (non demandé dans le sujet, mais recommandé pour 1.4.6 AAA).
