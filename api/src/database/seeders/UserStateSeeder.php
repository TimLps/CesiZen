<?php

namespace Database\Seeders;

use App\Models\UserState;
use Illuminate\Database\Seeder;

class UserStateSeeder extends Seeder
{
    public function run(): void
    {
        $states = [
            ['name' => UserState::ACTIVE,   'label' => 'Actif'],
            ['name' => UserState::INACTIVE, 'label' => 'Inactif'],
            ['name' => UserState::BANNED,   'label' => 'Banni'],
        ];

        foreach ($states as $state) {
            UserState::updateOrCreate(['name' => $state['name']], $state);
        }
    }
}
