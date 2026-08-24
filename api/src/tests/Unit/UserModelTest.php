<?php

namespace Tests\Unit;

use App\Models\Role;
use App\Models\User;
use App\Models\UserState;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

/**
 * Test unitaire — Logique du modèle User
 * Vérifie les helpers de rôle/état sans passer par HTTP.
 */
class UserModelTest extends TestCase
{
    use RefreshDatabase;

    public function test_admin_helper_returns_true_when_user_has_admin_role(): void
    {
        $adminRole  = Role::create(['name' => Role::ADMIN, 'label' => 'Administrateur']);
        $activeState = UserState::create(['name' => UserState::ACTIVE, 'label' => 'Actif']);

        $user = User::create([
            'first_name'    => 'Alice',
            'last_name'     => 'Admin',
            'email'         => 'alice@cesizen.fr',
            'password'      => 'password',
            'id_role'       => $adminRole->id_role,
            'id_user_state' => $activeState->id_user_state,
        ])->load(['role', 'userState']);

        $this->assertTrue($user->isAdmin());
        $this->assertFalse($user->isUser());
        $this->assertTrue($user->isActive());
    }

    public function test_full_name_accessor(): void
    {
        $role  = Role::create(['name' => Role::USER, 'label' => 'Utilisateur']);
        $state = UserState::create(['name' => UserState::ACTIVE, 'label' => 'Actif']);

        $user = User::create([
            'first_name'    => 'Jean',
            'last_name'     => 'Dupont',
            'email'         => 'jean@cesizen.fr',
            'password'      => 'password',
            'id_role'       => $role->id_role,
            'id_user_state' => $state->id_user_state,
        ]);

        $this->assertEquals('Jean Dupont', $user->full_name);
    }

    public function test_inactive_user_helper(): void
    {
        $role     = Role::create(['name' => Role::USER, 'label' => 'Utilisateur']);
        $inactive = UserState::create(['name' => UserState::INACTIVE, 'label' => 'Inactif']);

        $user = User::create([
            'first_name'    => 'Bob',
            'last_name'     => 'Banni',
            'email'         => 'bob@cesizen.fr',
            'password'      => 'password',
            'id_role'       => $role->id_role,
            'id_user_state' => $inactive->id_user_state,
        ])->load('userState');

        $this->assertFalse($user->isActive());
    }
}
