<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;

class DatabaseSeeder extends Seeder
{
    public function run(): void
    {
        $this->call([
            RoleSeeder::class,
            UserStateSeeder::class,
            AdminUserSeeder::class,
            EmotionSeeder::class,
            InfoPageCategorySeeder::class,
            InfoPageSeeder::class,
        ]);
    }
}
