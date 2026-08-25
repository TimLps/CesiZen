<?php

namespace Tests\Feature;

use App\Models\Role;
use App\Models\User;
use App\Models\UserState;
use Database\Seeders\RoleSeeder;
use Database\Seeders\UserStateSeeder;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\Hash;
use PHPUnit\Framework\Attributes\DataProvider;
use Tests\TestCase;

/**
 * La politique de mot de passe est déclarée une seule fois, via
 * Password::defaults() dans AppServiceProvider. Ces tests vérifient qu'elle
 * s'applique effectivement aux six points d'entrée qui acceptent un mot de
 * passe — une règle centralisée ne vaut que si tous s'y réfèrent réellement.
 */
class PasswordPolicyTest extends TestCase
{
    use RefreshDatabase;

    private const FAIBLE  = 'motdepasse';
    private const CONFORME = 'MotDePasse2026!';

    protected function setUp(): void
    {
        parent::setUp();
        $this->seed([RoleSeeder::class, UserStateSeeder::class]);
    }

    private function creerUtilisateur(string $role, string $email): User
    {
        return User::create([
            'first_name'    => 'Test',
            'last_name'     => ucfirst($role),
            'email'         => $email,
            'password'      => Hash::make(self::CONFORME),
            'id_role'       => Role::where('name', $role)->value('id_role'),
            'id_user_state' => UserState::where('name', UserState::ACTIVE)->value('id_user_state'),
        ]);
    }

    private function entete(User $user): array
    {
        return ['Authorization' => 'Bearer ' . $user->createToken('test')->plainTextToken];
    }

    // ── Point d'entrée 1 : inscription ────────────────────────────────────

    public static function motsDePasseRefuses(): array
    {
        return [
            'trop court'     => ['Court1!'],
            'sans majuscule' => ['motdepasse2026!'],
            'sans chiffre'   => ['MotDePasseSansChiffre!'],
            'sans symbole'   => ['MotDePasse2026'],
        ];
    }

    #[DataProvider('motsDePasseRefuses')]
    public function test_register_rejects_weak_passwords(string $password): void
    {
        $response = $this->postJson('/api/auth/register', [
            'first_name'            => 'Marie',
            'last_name'             => 'Test',
            'email'                 => 'marie@example.com',
            'password'              => $password,
            'password_confirmation' => $password,
        ]);

        $response->assertStatus(422);
        $response->assertJsonValidationErrors(['password']);
        $this->assertDatabaseMissing('users', ['email' => 'marie@example.com']);
    }

    public function test_register_accepts_a_compliant_password(): void
    {
        $this->postJson('/api/auth/register', [
            'first_name'            => 'Marie',
            'last_name'             => 'Test',
            'email'                 => 'marie@example.com',
            'password'              => self::CONFORME,
            'password_confirmation' => self::CONFORME,
        ])->assertCreated();
    }

    // ── Point d'entrée 2 : réinitialisation ───────────────────────────────

    public function test_reset_password_rejects_a_weak_password(): void
    {
        $this->creerUtilisateur(Role::USER, 'reset@example.com');

        $response = $this->postJson('/api/auth/reset-password', [
            'email'                 => 'reset@example.com',
            'token'                 => 'jeton-de-test',
            'password'              => self::FAIBLE,
            'password_confirmation' => self::FAIBLE,
        ]);

        $response->assertStatus(422);
        $response->assertJsonValidationErrors(['password']);
    }

    // ── Point d'entrée 3 : mise à jour du profil ──────────────────────────

    public function test_profile_update_rejects_a_weak_password(): void
    {
        $user = $this->creerUtilisateur(Role::USER, 'profil@example.com');

        $response = $this->withHeaders($this->entete($user))
            ->putJson('/api/profile', [
                'password'              => self::FAIBLE,
                'password_confirmation' => self::FAIBLE,
            ]);

        $response->assertStatus(422);
        $response->assertJsonValidationErrors(['password']);
    }

    // ── Point d'entrée 4 : changement de mot de passe ─────────────────────

    public function test_password_change_rejects_a_weak_new_password(): void
    {
        $user = $this->creerUtilisateur(Role::USER, 'changement@example.com');

        $response = $this->withHeaders($this->entete($user))
            ->postJson('/api/profile/password', [
                'current_password'          => self::CONFORME,
                'new_password'              => self::FAIBLE,
                'new_password_confirmation' => self::FAIBLE,
            ]);

        $response->assertStatus(422);
        $response->assertJsonValidationErrors(['new_password']);
    }

    public function test_password_change_accepts_a_compliant_new_password(): void
    {
        $user = $this->creerUtilisateur(Role::USER, 'changement@example.com');

        $this->withHeaders($this->entete($user))
            ->postJson('/api/profile/password', [
                'current_password'          => self::CONFORME,
                'new_password'              => 'AutreMotDePasse2026!',
                'new_password_confirmation' => 'AutreMotDePasse2026!',
            ])->assertOk();

        $this->assertTrue(Hash::check('AutreMotDePasse2026!', $user->fresh()->password));
    }

    // ── Points d'entrée 5 et 6 : création et modification par un admin ────

    public function test_admin_user_creation_rejects_a_weak_password(): void
    {
        $admin = $this->creerUtilisateur(Role::ADMIN, 'admin@example.com');

        $response = $this->withHeaders($this->entete($admin))
            ->postJson('/api/admin/users', [
                'first_name' => 'Nouveau',
                'last_name'  => 'Compte',
                'email'      => 'nouveau@example.com',
                'password'   => self::FAIBLE,
                'id_role'    => Role::where('name', Role::USER)->value('id_role'),
            ]);

        $response->assertStatus(422);
        $response->assertJsonValidationErrors(['password']);
        $this->assertDatabaseMissing('users', ['email' => 'nouveau@example.com']);
    }

    public function test_admin_user_update_rejects_a_weak_password(): void
    {
        $admin = $this->creerUtilisateur(Role::ADMIN, 'admin@example.com');
        $cible = $this->creerUtilisateur(Role::USER, 'cible@example.com');

        $response = $this->withHeaders($this->entete($admin))
            ->putJson("/api/admin/users/{$cible->id_user}", [
                'password' => self::FAIBLE,
            ]);

        $response->assertStatus(422);
        $response->assertJsonValidationErrors(['password']);
    }
}
