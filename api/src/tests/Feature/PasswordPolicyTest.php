<?php

namespace Tests\Feature;

use Database\Seeders\RoleSeeder;
use Database\Seeders\UserStateSeeder;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class PasswordPolicyTest extends TestCase
{
    use RefreshDatabase;

    protected function setUp(): void
    {
        parent::setUp();
        $this->seed([RoleSeeder::class, UserStateSeeder::class]);
    }

    public static function motsDePasseRefuses(): array
    {
        return [
            'trop court'      => ['Court1!'],
            'sans majuscule'  => ['motdepasse2026!'],
            'sans chiffre'    => ['MotDePasseSansChiffre!'],
            'sans symbole'    => ['MotDePasse2026'],
        ];
    }

    /**
     * @dataProvider motsDePasseRefuses
     */
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
            'password'              => 'MotDePasse2026!',
            'password_confirmation' => 'MotDePasse2026!',
        ])->assertCreated();
    }
}
