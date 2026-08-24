<?php

namespace Database\Seeders;

use App\Models\Role;
use App\Models\User;
use App\Models\UserState;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\Hash;

class AdminUserSeeder extends Seeder
{
    public function run(): void
    {
        $adminRoleId = Role::where('name', Role::ADMIN)->value('id_role');
        $userRoleId  = Role::where('name', Role::USER)->value('id_role');
        $activeId    = UserState::where('name', UserState::ACTIVE)->value('id_user_state');

        // ── Admin ────────────────────────────────────────────────────────
        User::updateOrCreate(
            ['email' => 'admin@cesizen.fr'],
            [
                'first_name'    => 'Admin',
                'last_name'     => 'CESIZen',
                'password'      => Hash::make('password'),
                'city'          => 'Paris',
                'birth_date'    => '1990-01-01',
                'id_role'       => $adminRoleId,
                'id_user_state' => $activeId,
            ]
        );

        // ── Utilisateur de démonstration ──────────────────────────────────
        User::updateOrCreate(
            ['email' => 'demo@cesizen.fr'],
            [
                'first_name'    => 'Tim',
                'last_name'     => 'Démo',
                'password'      => Hash::make('password'),
                'city'          => 'Nancy',
                'birth_date'    => '1995-06-15',
                'id_role'       => $userRoleId,
                'id_user_state' => $activeId,
            ]
        );
    }
}
