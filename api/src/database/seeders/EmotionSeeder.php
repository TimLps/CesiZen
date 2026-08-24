<?php

namespace Database\Seeders;

use App\Models\Emotion;
use App\Models\EmotionCategory;
use Illuminate\Database\Seeder;

class EmotionSeeder extends Seeder
{
    /**
     * Référentiel d'émotions issu du cahier des charges CESIZen
     * (cf. CDA - Activité 1, page 8-9 : émotions de base + émotions niveau 2).
     *
     * Le champ `feeling_label` est la forme adjectivale utilisée dans
     * la phrase « Vous vous sentez ... » côté UI.
     *
     * Couleurs pastels alignées sur la palette graphique (cf. maquette).
     */
    public function run(): void
    {
        $data = [
            [
                'name'          => 'Joie',
                'feeling_label' => 'joyeux',
                'color_hex'     => '#B0E0E6',
                'icon'          => 'sentiment_very_satisfied',
                'sort_order'    => 1,
                'emotions' => [
                    'Fierté'         => 'fier',
                    'Contentement'   => 'content',
                    'Enchantement'   => 'enchanté',
                    'Excitation'     => 'excité',
                    'Émerveillement' => 'émerveillé',
                    'Gratitude'      => 'reconnaissant',
                ],
            ],
            [
                'name'          => 'Colère',
                'feeling_label' => 'en colère',
                'color_hex'     => '#F8C8D8',
                'icon'          => 'sentiment_very_dissatisfied',
                'sort_order'    => 2,
                'emotions' => [
                    'Frustration'  => 'frustré',
                    'Irritation'   => 'irrité',
                    'Rage'         => 'enragé',
                    'Ressentiment' => 'plein de ressentiment',
                    'Agacement'    => 'agacé',
                    'Hostilité'    => 'hostile',
                ],
            ],
            [
                'name'          => 'Peur',
                'feeling_label' => 'apeuré',
                'color_hex'     => '#C9DAF8',
                'icon'          => 'mood_bad',
                'sort_order'    => 3,
                'emotions' => [
                    'Inquiétude'   => 'inquiet',
                    'Anxiété'      => 'anxieux',
                    'Terreur'      => 'terrifié',
                    'Appréhension' => 'plein d\'appréhension',
                    'Panique'      => 'paniqué',
                    'Crainte'      => 'craintif',
                ],
            ],
            [
                'name'          => 'Tristesse',
                'feeling_label' => 'triste',
                'color_hex'     => '#778899',
                'icon'          => 'sentiment_dissatisfied',
                'sort_order'    => 4,
                'emotions' => [
                    'Chagrin'    => 'plein de chagrin',
                    'Mélancolie' => 'mélancolique',
                    'Abattement' => 'abattu',
                    'Désespoir'  => 'désespéré',
                    'Solitude'   => 'seul',
                    'Dépression' => 'déprimé',
                ],
            ],
            [
                'name'          => 'Surprise',
                'feeling_label' => 'surpris',
                'color_hex'     => '#FFF2CC',
                'icon'          => 'mood',
                'sort_order'    => 5,
                'emotions' => [
                    'Étonnement'   => 'étonné',
                    'Stupéfaction' => 'stupéfait',
                    'Sidération'   => 'sidéré',
                    'Incrédulité'  => 'incrédule',
                    'Confusion'    => 'confus',
                ],
            ],
            [
                'name'          => 'Dégoût',
                'feeling_label' => 'dégoûté',
                'color_hex'     => '#F0D9F5',
                'icon'          => 'sick',
                'sort_order'    => 6,
                'emotions' => [
                    'Répulsion'      => 'pris de répulsion',
                    'Déplaisir'      => 'mal à l\'aise',
                    'Nausée'         => 'écœuré',
                    'Dédain'         => 'dédaigneux',
                    'Horreur'        => 'horrifié',
                    'Dégoût profond' => 'profondément dégoûté',
                ],
            ],
        ];

        foreach ($data as $cat) {
            $category = EmotionCategory::updateOrCreate(
                ['name' => $cat['name']],
                [
                    'feeling_label' => $cat['feeling_label'],
                    'color_hex'     => $cat['color_hex'],
                    'icon'          => $cat['icon'],
                    'sort_order'    => $cat['sort_order'],
                    'is_active'     => true,
                ]
            );

            foreach ($cat['emotions'] as $emotionName => $emotionLabel) {
                Emotion::updateOrCreate(
                    [
                        'id_emotion_category' => $category->id_emotion_category,
                        'name'                => $emotionName,
                    ],
                    [
                        'feeling_label' => $emotionLabel,
                        'is_active'     => true,
                    ]
                );
            }
        }
    }
}
