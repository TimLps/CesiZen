<?php

namespace Database\Seeders;

use App\Models\InfoPageCategory;
use Illuminate\Database\Seeder;

class InfoPageCategorySeeder extends Seeder
{
    public function run(): void
    {
        $categories = [
            [
                'name'       => 'Stress et anxiété',
                'slug'       => 'stress-et-anxiete',
                'icon'       => 'bolt_outlined',
                'color_hex'  => '#F8C8D8',
                'sort_order' => 1,
            ],
            [
                'name'       => 'Émotions',
                'slug'       => 'emotions',
                'icon'       => 'emoji_emotions_outlined',
                'color_hex'  => '#B0E0E6',
                'sort_order' => 2,
            ],
            [
                'name'       => 'Sommeil',
                'slug'       => 'sommeil',
                'icon'       => 'nightlight_outlined',
                'color_hex'  => '#C9DAF8',
                'sort_order' => 3,
            ],
            [
                'name'       => 'Activité physique',
                'slug'       => 'activite-physique',
                'icon'       => 'directions_run',
                'color_hex'  => '#FFF2CC',
                'sort_order' => 4,
            ],
            [
                'name'       => 'Vie sociale',
                'slug'       => 'vie-sociale',
                'icon'       => 'group_outlined',
                'color_hex'  => '#E6E6FA',
                'sort_order' => 5,
            ],
            [
                'name'       => 'Bien-être au quotidien',
                'slug'       => 'bien-etre',
                'icon'       => 'self_improvement',
                'color_hex'  => '#B6E5C5',
                'sort_order' => 6,
            ],
            [
                'name'       => 'Informations pratiques',
                'slug'       => 'pratique',
                'icon'       => 'gavel_outlined',
                'color_hex'  => '#F0F8FF',
                'sort_order' => 99,
            ],
        ];

        foreach ($categories as $cat) {
            InfoPageCategory::updateOrCreate(
                ['slug' => $cat['slug']],
                $cat + ['is_active' => true],
            );
        }
    }
}
