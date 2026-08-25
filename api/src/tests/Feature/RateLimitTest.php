<?php

namespace Tests\Feature;

use Database\Seeders\RoleSeeder;
use Database\Seeders\UserStateSeeder;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class RateLimitTest extends TestCase
{
    use RefreshDatabase;

    protected function setUp(): void
    {
        parent::setUp();
        $this->seed([RoleSeeder::class, UserStateSeeder::class]);
    }

    /**
     * Cinq tentatives de connexion par minute et par IP. La sixième doit
     * être refusée avant même d'atteindre le contrôleur.
     */
    public function test_login_is_rate_limited_after_five_attempts(): void
    {
        $payload = ['email' => 'inconnu@example.com', 'password' => 'mauvais-mot-de-passe'];

        for ($i = 1; $i <= 5; $i++) {
            $this->postJson('/api/auth/login', $payload)
                ->assertStatus(401, "La tentative {$i} aurait dû être traitée, pas bloquée.");
        }

        $response = $this->postJson('/api/auth/login', $payload);

        $response->assertStatus(429);
        $response->assertHeader('Retry-After');
    }

    /**
     * La limite couvre l'ensemble des routes d'authentification publiques,
     * pas seulement /login : /register permet l'énumération de comptes et
     * /forgot-password l'envoi massif de courriels.
     */
    public function test_forgot_password_is_rate_limited(): void
    {
        for ($i = 1; $i <= 5; $i++) {
            $this->postJson('/api/auth/forgot-password', ['email' => 'inconnu@example.com']);
        }

        $this->postJson('/api/auth/forgot-password', ['email' => 'inconnu@example.com'])
            ->assertStatus(429);
    }
}
