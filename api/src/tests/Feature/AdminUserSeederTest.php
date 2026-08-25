<?php

namespace Tests\Feature;

use App\Models\User;
use Database\Seeders\AdminUserSeeder;
use Database\Seeders\RoleSeeder;
use Database\Seeders\UserStateSeeder;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\Hash;
use Tests\TestCase;

/**
 * Le seeder créait auparavant le compte d'administration avec le mot de
 * passe "password", écrit en clair dans un fichier versionné. Ces tests
 * verrouillent le comportement corrigé.
 */
class AdminUserSeederTest extends TestCase
{
    use RefreshDatabase;

    protected function setUp(): void
    {
        parent::setUp();
        $this->seed([RoleSeeder::class, UserStateSeeder::class]);
        $this->oublierVariables();
    }

    protected function tearDown(): void
    {
        $this->oublierVariables();
        parent::tearDown();
    }

    private function oublierVariables(): void
    {
        foreach (['SEED_ADMIN_PASSWORD', 'SEED_DEMO_PASSWORD'] as $variable) {
            unset($_ENV[$variable], $_SERVER[$variable]);
        }
    }

    private function definirVariable(string $variable, string $valeur): void
    {
        $_ENV[$variable] = $valeur;
        $_SERVER[$variable] = $valeur;
    }

    public function test_seeder_uses_the_configured_passwords(): void
    {
        $this->definirVariable('SEED_ADMIN_PASSWORD', 'AdministrateurCesi2026!');
        $this->definirVariable('SEED_DEMO_PASSWORD', 'DemonstrationCesi2026!');

        $this->seed([AdminUserSeeder::class]);

        $admin = User::where('email', 'admin@cesizen.fr')->firstOrFail();
        $demo  = User::where('email', 'demo@cesizen.fr')->firstOrFail();

        $this->assertTrue(Hash::check('AdministrateurCesi2026!', $admin->password));
        $this->assertTrue(Hash::check('DemonstrationCesi2026!', $demo->password));
    }

    /**
     * Sans variable, le seeder engendre un mot de passe aléatoire plutôt que
     * de retomber sur une valeur par défaut. C'est le cœur de la correction :
     * une valeur de repli finit toujours par être celle qui tourne en
     * production.
     */
    public function test_seeder_generates_a_random_password_when_unconfigured(): void
    {
        $this->seed([AdminUserSeeder::class]);

        $admin = User::where('email', 'admin@cesizen.fr')->firstOrFail();

        $this->assertFalse(
            Hash::check('password', $admin->password),
            "Le seeder ne doit plus créer le compte d'administration avec un mot de passe prévisible."
        );
        $this->assertFalse(Hash::check('', $admin->password));
    }

    /**
     * Deux exécutions consécutives sans variable ne doivent pas produire le
     * même mot de passe : c'est ce qui distingue un aléa d'une constante.
     */
    public function test_generated_passwords_differ_between_runs(): void
    {
        $this->seed([AdminUserSeeder::class]);
        $premier = User::where('email', 'admin@cesizen.fr')->value('password');

        $this->seed([AdminUserSeeder::class]);
        $second = User::where('email', 'admin@cesizen.fr')->value('password');

        $this->assertNotSame($premier, $second);
    }
}
