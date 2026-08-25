<?php

namespace Tests\Feature;

use App\Models\Role;
use App\Models\User;
use App\Models\UserState;
use Database\Seeders\RoleSeeder;
use Database\Seeders\UserStateSeeder;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\Hash;
use Tests\TestCase;

class AuthTest extends TestCase
{
    use RefreshDatabase;

    protected function setUp(): void
    {
        parent::setUp();
        $this->seed([RoleSeeder::class, UserStateSeeder::class]);
    }

    public function test_register_creates_a_user_and_returns_a_token(): void
    {
        $response = $this->postJson('/api/auth/register', [
            'first_name'            => 'Marie',
            'last_name'             => 'Test',
            'email'                 => 'marie@example.com',
            'password'              => 'MotDePasse2026!',
            'password_confirmation' => 'MotDePasse2026!',
            'city'                  => 'Lyon',
        ]);

        $response->assertCreated();
        $response->assertJsonStructure(['message', 'token', 'user' => ['id_user', 'email']]);
        $this->assertDatabaseHas('users', ['email' => 'marie@example.com']);
    }

    public function test_register_fails_when_password_mismatch(): void
    {
        $response = $this->postJson('/api/auth/register', [
            'first_name'            => 'Marie',
            'last_name'             => 'Test',
            'email'                 => 'marie@example.com',
            'password'              => 'MotDePasse2026!',
            'password_confirmation' => 'AutreChose2026!',
        ]);

        $response->assertStatus(422);
        $response->assertJsonValidationErrors(['password']);
    }

    public function test_login_with_valid_credentials_returns_token(): void
    {
        $userRoleId = Role::where('name', Role::USER)->value('id_role');
        $activeId   = UserState::where('name', UserState::ACTIVE)->value('id_user_state');

        User::create([
            'first_name'    => 'Login',
            'last_name'     => 'Test',
            'email'         => 'login@example.com',
            'password'      => Hash::make('password'),
            'id_role'       => $userRoleId,
            'id_user_state' => $activeId,
        ]);

        $response = $this->postJson('/api/auth/login', [
            'email'    => 'login@example.com',
            'password' => 'password',
        ]);

        $response->assertOk();
        $response->assertJsonStructure(['token', 'user']);
    }

    public function test_login_fails_with_wrong_password(): void
    {
        $userRoleId = Role::where('name', Role::USER)->value('id_role');
        $activeId   = UserState::where('name', UserState::ACTIVE)->value('id_user_state');

        User::create([
            'first_name'    => 'Login',
            'last_name'     => 'Test',
            'email'         => 'login@example.com',
            'password'      => Hash::make('password'),
            'id_role'       => $userRoleId,
            'id_user_state' => $activeId,
        ]);

        $response = $this->postJson('/api/auth/login', [
            'email'    => 'login@example.com',
            'password' => 'mauvais',
        ]);

        $response->assertStatus(401);
    }

    public function test_inactive_user_cannot_login(): void
    {
        $userRoleId = Role::where('name', Role::USER)->value('id_role');
        $inactiveId = UserState::where('name', UserState::INACTIVE)->value('id_user_state');

        User::create([
            'first_name'    => 'Inactif',
            'last_name'     => 'Test',
            'email'         => 'inactif@example.com',
            'password'      => Hash::make('password'),
            'id_role'       => $userRoleId,
            'id_user_state' => $inactiveId,
        ]);

        $response = $this->postJson('/api/auth/login', [
            'email'    => 'inactif@example.com',
            'password' => 'password',
        ]);

        $response->assertStatus(403);
    }

    public function test_authenticated_user_can_get_me(): void
    {
        $userRoleId = Role::where('name', Role::USER)->value('id_role');
        $activeId   = UserState::where('name', UserState::ACTIVE)->value('id_user_state');

        $user = User::create([
            'first_name'    => 'Me',
            'last_name'     => 'Test',
            'email'         => 'me@example.com',
            'password'      => Hash::make('password'),
            'id_role'       => $userRoleId,
            'id_user_state' => $activeId,
        ]);

        $token = $user->createToken('test')->plainTextToken;

        $response = $this->withHeader('Authorization', "Bearer $token")
            ->getJson('/api/auth/me');

        $response->assertOk();
        $response->assertJsonPath('email', 'me@example.com');
    }
}
