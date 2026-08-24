<?php

namespace Database\Seeders;

use App\Models\InfoPage;
use App\Models\InfoPageCategory;
use App\Models\Role;
use App\Models\User;
use Illuminate\Database\Seeder;

class InfoPageSeeder extends Seeder
{
    public function run(): void
    {
        // Auteur par défaut : le premier admin seedé (utilisé pour created_by/updated_by).
        $adminRoleId = Role::where('name', 'admin')->value('id_role');
        $defaultAuthor = $adminRoleId
            ? User::where('id_role', $adminRoleId)->orderBy('id_user')->first()
            : null;
        $authorId = $defaultAuthor?->id_user;

        // Lookup slug catégorie → id
        $categoryIds = InfoPageCategory::pluck('id_info_page_category', 'slug');

        $pages = [
            [
                'slug'         => 'comprendre-le-stress',
                'title'        => 'Comprendre le stress',
                'menu_label'   => 'Le stress',
                'category'     => 'stress-et-anxiete',
                'sort_order'   => 1,
                'content'      => "<h2>Qu'est-ce que le stress ?</h2>"
                    . "<p>Le stress est une réponse naturelle de l'organisme face à une situation perçue comme menaçante ou exigeante. Il mobilise notre énergie et nos ressources pour faire face. À court terme, il peut être bénéfique : il nous rend plus alertes et plus performants.</p>"
                    . "<h3>Stress aigu et stress chronique</h3>"
                    . "<p>Le stress aigu disparaît lorsque la situation se résout. Le stress chronique, lui, s'installe et peut entraîner troubles du sommeil, anxiété, fatigue persistante, troubles digestifs ou baisse d'immunité.</p>"
                    . "<h3>Apprendre à le réguler</h3>"
                    . "<p>Identifier ses déclencheurs, pratiquer une activité physique régulière, dormir suffisamment, entretenir des liens sociaux et s'accorder des temps de pause sont des leviers essentiels au quotidien.</p>",
            ],
            [
                'slug'         => 'sante-mentale-au-quotidien',
                'title'        => 'Prendre soin de sa santé mentale au quotidien',
                'menu_label'   => 'Santé mentale au quotidien',
                'category'     => 'bien-etre',
                'sort_order'   => 1,
                'content'      => "<h2>La santé mentale, l'affaire de tous</h2>"
                    . "<p>La santé mentale ne se résume pas à l'absence de troubles psychiques. C'est un état de bien-être qui permet à chacun de réaliser son potentiel, de faire face aux difficultés normales de la vie, de travailler de manière productive et de contribuer à sa communauté.</p>"
                    . "<h3>Quelques gestes simples</h3>"
                    . "<ul>"
                    . "<li>Maintenir des liens sociaux nourrissants</li>"
                    . "<li>Pratiquer une activité physique régulière, même modérée</li>"
                    . "<li>Veiller à un sommeil de qualité (7 à 9 heures)</li>"
                    . "<li>Limiter alcool, tabac et écrans avant le coucher</li>"
                    . "<li>S'autoriser des moments pour soi sans culpabilité</li>"
                    . "<li>Demander de l'aide en cas de besoin : proche, médecin traitant, ou professionnel de santé mentale</li>"
                    . "</ul>",
            ],
            [
                'slug'         => 'identifier-ses-emotions',
                'title'        => 'Identifier et accueillir ses émotions',
                'menu_label'   => 'Identifier ses émotions',
                'category'     => 'emotions',
                'sort_order'   => 1,
                'content'      => "<h2>Pourquoi tenir un journal d'émotions ?</h2>"
                    . "<p>Mettre des mots sur ce que l'on ressent est la première étape pour mieux se comprendre. Un journal permet d'identifier des schémas, des déclencheurs, et de prendre du recul sur ses réactions.</p>"
                    . "<h3>Les six grandes familles</h3>"
                    . "<p>La psychologie moderne identifie six émotions de base : la joie, la colère, la peur, la tristesse, la surprise et le dégoût. Chacune peut prendre des formes plus subtiles : l'enchantement, la fierté, la frustration, l'inquiétude...</p>"
                    . "<p>Le tracker de CESIZen vous aide à explorer ces nuances jour après jour, à votre rythme.</p>",
            ],
            [
                'slug'         => 'sommeil-et-sante-mentale',
                'title'        => 'Sommeil et santé mentale',
                'menu_label'   => 'Sommeil',
                'category'     => 'sommeil',
                'sort_order'   => 1,
                'content'      => "<h2>Un pilier souvent négligé</h2>"
                    . "<p>Le sommeil joue un rôle central dans la régulation des émotions, la mémoire et la résistance au stress. Un sommeil insuffisant ou de mauvaise qualité augmente le risque d'anxiété et de troubles de l'humeur.</p>"
                    . "<h3>Bonnes pratiques d'hygiène du sommeil</h3>"
                    . "<ul>"
                    . "<li>Conserver des horaires de coucher et de lever réguliers</li>"
                    . "<li>Réserver la chambre au sommeil (pas d'écran, lumière tamisée)</li>"
                    . "<li>Éviter caféine et repas lourds en soirée</li>"
                    . "<li>Pratiquer un rituel apaisant avant le coucher : lecture, étirements doux, journal d'émotions</li>"
                    . "</ul>"
                    . "<p>Si les difficultés persistent au-delà de quelques semaines, consultez votre médecin traitant.</p>",
            ],
            [
                'slug'         => 'anxiete-comprendre',
                'title'        => "Comprendre l'anxiété",
                'menu_label'   => 'Anxiété',
                'category'     => 'stress-et-anxiete',
                'sort_order'   => 2,
                'content'      => "<h2>L'anxiété, une émotion universelle</h2>"
                    . "<p>L'anxiété est une réaction normale face à l'incertitude. Elle ne devient problématique que lorsqu'elle est disproportionnée, persistante, ou qu'elle entrave la vie quotidienne.</p>"
                    . "<h3>Reconnaître les signaux</h3>"
                    . "<ul>"
                    . "<li>Pensées en boucle, anticipation négative</li>"
                    . "<li>Tensions musculaires, oppression thoracique</li>"
                    . "<li>Difficulté à se concentrer, irritabilité</li>"
                    . "<li>Troubles du sommeil ou de l'appétit</li>"
                    . "</ul>"
                    . "<h3>Quand consulter ?</h3>"
                    . "<p>Si ces signaux persistent plus de deux semaines ou affectent votre quotidien, parlez-en à un professionnel de santé. Des prises en charge efficaces existent.</p>",
            ],
            [
                'slug'         => 'activite-physique-bien-etre',
                'title'        => 'Activité physique et bien-être mental',
                'menu_label'   => 'Activité physique',
                'category'     => 'activite-physique',
                'sort_order'   => 1,
                'content'      => "<h2>Bouger pour se sentir mieux</h2>"
                    . "<p>L'activité physique régulière agit comme un véritable antidépresseur naturel. Elle stimule la production d'endorphines, améliore le sommeil et réduit l'anxiété.</p>"
                    . "<h3>30 minutes par jour, ça suffit</h3>"
                    . "<p>L'OMS recommande au moins 150 minutes d'activité modérée par semaine. Marche rapide, vélo, natation, jardinage : toutes les activités comptent.</p>"
                    . "<h3>Trouver ce qui vous convient</h3>"
                    . "<p>Le meilleur sport est celui que l'on pratique avec plaisir et régularité. Commencez petit, soyez bienveillant avec vous-même, et augmentez progressivement.</p>",
            ],
            [
                'slug'         => 'liens-sociaux',
                'title'        => 'L\'importance des liens sociaux',
                'menu_label'   => 'Liens sociaux',
                'category'     => 'vie-sociale',
                'sort_order'   => 1,
                'content'      => "<h2>Nous sommes des êtres sociaux</h2>"
                    . "<p>La qualité de nos relations est un des prédicteurs les plus solides de bien-être à long terme. Entretenir des liens authentiques est aussi protecteur pour la santé que ne pas fumer ou pratiquer une activité physique.</p>"
                    . "<h3>Cultiver ses liens</h3>"
                    . "<ul>"
                    . "<li>Prendre régulièrement des nouvelles de ses proches</li>"
                    . "<li>Privilégier la qualité à la quantité des échanges</li>"
                    . "<li>Oser exprimer ses besoins et ses émotions</li>"
                    . "<li>Rejoindre des communautés autour de ses passions</li>"
                    . "</ul>"
                    . "<p>L'isolement prolongé est un facteur de risque majeur pour la santé mentale. Si vous vous sentez seul, demander de l'aide est un acte de courage, pas de faiblesse.</p>",
            ],
            [
                'slug'         => 'parler-de-sa-sante-mentale',
                'title'        => 'Parler de sa santé mentale',
                'menu_label'   => 'En parler',
                'category'     => 'vie-sociale',
                'sort_order'   => 2,
                'content'      => "<h2>Briser le silence</h2>"
                    . "<p>Parler de ce que l'on traverse est souvent la marche la plus difficile. Mais c'est aussi la plus libératrice : elle permet de déposer un poids et d'ouvrir la porte à l'aide.</p>"
                    . "<h3>À qui en parler ?</h3>"
                    . "<ul>"
                    . "<li>Un proche de confiance</li>"
                    . "<li>Votre médecin traitant, premier interlocuteur de santé</li>"
                    . "<li>Un psychologue, psychiatre ou psychothérapeute</li>"
                    . "<li>Une ligne d'écoute anonyme et gratuite</li>"
                    . "</ul>"
                    . "<h3>Numéros utiles</h3>"
                    . "<ul>"
                    . "<li><strong>3114</strong> — Numéro national de prévention du suicide (24h/24, gratuit)</li>"
                    . "<li><strong>SOS Amitié</strong> — 09 72 39 40 50</li>"
                    . "<li><strong>Fil Santé Jeunes</strong> — 0 800 235 236 (12-25 ans)</li>"
                    . "</ul>",
            ],
            [
                'slug'         => 'pleine-conscience',
                'title'        => 'La pleine conscience au quotidien',
                'menu_label'   => 'Pleine conscience',
                'category'     => 'bien-etre',
                'sort_order'   => 2,
                'content'      => "<h2>Revenir à l'instant présent</h2>"
                    . "<p>La pleine conscience consiste à porter son attention, intentionnellement et sans jugement, sur ce qui se passe ici et maintenant. Elle permet de prendre du recul vis-à-vis du flot des pensées automatiques.</p>"
                    . "<h3>Trois exercices simples</h3>"
                    . "<ul>"
                    . "<li><strong>3 respirations conscientes</strong> : avant un repas, ressentez l'air qui entre et sort, sans rien changer.</li>"
                    . "<li><strong>Scan corporel</strong> : passez en revue chaque partie du corps, des pieds à la tête, en notant les sensations.</li>"
                    . "<li><strong>Une chose à la fois</strong> : pendant 5 minutes, faites une activité simple (boire un thé, marcher) en y portant toute votre attention.</li>"
                    . "</ul>"
                    . "<p>Quelques minutes par jour suffisent à observer des bénéfices durables sur la régulation émotionnelle.</p>",
            ],
            [
                'slug'         => 'alimentation-humeur',
                'title'        => 'Alimentation et humeur',
                'menu_label'   => 'Alimentation',
                'category'     => 'bien-etre',
                'sort_order'   => 3,
                'content'      => "<h2>Ce que l'on mange influence ce que l'on ressent</h2>"
                    . "<p>De plus en plus de recherches mettent en lumière le lien étroit entre alimentation et santé mentale. Le microbiote intestinal communique en permanence avec le cerveau via le nerf vague.</p>"
                    . "<h3>Privilégier</h3>"
                    . "<ul>"
                    . "<li>Fruits, légumes et légumineuses (fibres et antioxydants)</li>"
                    . "<li>Poissons gras (oméga-3 favorables à l'humeur)</li>"
                    . "<li>Aliments fermentés (yaourt, kéfir, choucroute) pour le microbiote</li>"
                    . "<li>Hydratation régulière tout au long de la journée</li>"
                    . "</ul>"
                    . "<h3>Limiter</h3>"
                    . "<p>Sucres ajoutés, ultra-transformés et excès de caféine peuvent aggraver anxiété et fatigue. La clé reste l'équilibre, pas la perfection.</p>",
            ],
            [
                'slug'         => 'gerer-les-pensees-negatives',
                'title'        => 'Gérer les pensées négatives',
                'menu_label'   => 'Pensées négatives',
                'category'     => 'stress-et-anxiete',
                'sort_order'   => 3,
                'content'      => "<h2>Les pensées ne sont pas des faits</h2>"
                    . "<p>Notre cerveau produit en permanence des pensées, dont une grande partie sont automatiques et négatives. Apprendre à les observer sans s'y identifier est un exercice fondamental.</p>"
                    . "<h3>La technique du recul</h3>"
                    . "<ol>"
                    . "<li><strong>Remarquer</strong> la pensée : « Je remarque que je pense que... »</li>"
                    . "<li><strong>Examiner</strong> les preuves : qu'est-ce qui valide cette pensée ? Qu'est-ce qui la contredit ?</li>"
                    . "<li><strong>Reformuler</strong> de manière plus nuancée et bienveillante.</li>"
                    . "</ol>"
                    . "<p>Tenir un journal d'émotions et de pensées est un excellent moyen d'identifier ses schémas récurrents. Le tracker CESIZen peut vous y aider.</p>",
            ],
            [
                'slug'         => 'mentions-legales',
                'title'        => 'Mentions légales',
                'menu_label'   => 'Mentions légales',
                'category'     => 'pratique',
                'sort_order'   => 1,
                'content'      => "<h2>Éditeur</h2>"
                    . "<p>CESIZen est une application développée par PRISM SARL dans le cadre d'un projet d'évaluation CDA, à destination du Ministère de la Santé et de la Prévention.</p>"
                    . "<h2>Hébergement</h2>"
                    . "<p>Données hébergées en France, sur des serveurs conformes au RGPD.</p>"
                    . "<h2>Données personnelles</h2>"
                    . "<p>Les données collectées sont strictement nécessaires au fonctionnement de l'application. Vous disposez d'un droit d'accès, de rectification, de portabilité et de suppression de vos données via votre profil ou en contactant <a href=\"mailto:contact@prism.fr\">contact@prism.fr</a>.</p>"
                    . "<h2>Avertissement</h2>"
                    . "<p>CESIZen est un outil de prévention et de sensibilisation. Il ne remplace en aucun cas une consultation médicale ou un suivi psychologique professionnel.</p>",
            ],
        ];

        foreach ($pages as $page) {
            $categorySlug = $page['category'];
            unset($page['category']);
            $page['id_info_page_category'] = $categoryIds[$categorySlug] ?? null;
            $page['is_published'] = true;
            $page['created_by'] = $authorId;
            $page['updated_by'] = $authorId;

            InfoPage::updateOrCreate(['slug' => $page['slug']], $page);
        }
    }
}
