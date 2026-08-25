<?php

namespace Database\Seeders;

use App\Models\Role;
use App\Models\User;
use App\Models\UserState;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Str;

class AdminUserSeeder extends Seeder
{
    public function run(): void
    {
        $adminPassword = $this->passwordFor('SEED_ADMIN_PASSWORD');
        $demoPassword  = $this->passwordFor('SEED_DEMO_PASSWORD');

        $adminRoleId = Role::where('name', Role::ADMIN)->value('id_role');
        $userRoleId  = Role::where('name', Role::USER)->value('id_role');
        $activeId    = UserState::where('name', UserState::ACTIVE)->value('id_user_state');

        // ── Admin ────────────────────────────────────────────────────────
        User::updateOrCreate(
            ['email' => 'admin@cesizen.fr'],
            [
                'first_name'    => 'Admin',
                'last_name'     => 'CESIZen',
                'password'      => Hash::make($adminPassword),
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
                'password'      => Hash::make($demoPassword),
                'city'          => 'Nancy',
                'birth_date'    => '1995-06-15',
                'id_role'       => $userRoleId,
                'id_user_state' => $activeId,
            ]
        );
    }

    /**
     * Mot de passe du compte à semer.
     *
     * Il est lu dans l'environnement. Aucune valeur par défaut n'est prévue :
     * si la variable est absente, un mot de passe aléatoire est engendré et
     * affiché une seule fois dans la sortie de la commande. Le compte reste
     * donc utilisable en développement, sans qu'aucun identifiant prévisible
     * n'existe dans le dépôt ni ne soit réintroduit par un oubli de
     * configuration en production.
     */
    private function passwordFor(string $variable): string
    {
        $password = env($variable);

        if (filled($password)) {
            return $password;
        }

        $password = Str::password(16);

        $this->command?->warn(
            "{$variable} n'est pas définie : mot de passe engendré pour cette exécution — {$password}"
        );

        return $password;
    }
}
