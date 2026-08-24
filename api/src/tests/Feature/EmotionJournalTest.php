<?php

namespace Tests\Feature;

use App\Models\Emotion;
use App\Models\EmotionCategory;
use App\Models\Role;
use App\Models\User;
use App\Models\UserState;
use Database\Seeders\RoleSeeder;
use Database\Seeders\UserStateSeeder;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\Hash;
use Tests\TestCase;

class EmotionJournalTest extends TestCase
{
    use RefreshDatabase;

    private User $user;
    private Emotion $emotion;

    protected function setUp(): void
    {
        parent::setUp();
        $this->seed([RoleSeeder::class, UserStateSeeder::class]);

        $cat = EmotionCategory::create([
            'name'       => 'Joie',
            'color_hex'  => '#B0E0E6',
            'sort_order' => 1,
            'is_active'  => true,
        ]);
        $this->emotion = Emotion::create([
            'id_emotion_category' => $cat->id_emotion_category,
            'name'                => 'Enchantement',
            'is_active'           => true,
        ]);

        $userRoleId = Role::where('name', Role::USER)->value('id_role');
        $activeId   = UserState::where('name', UserState::ACTIVE)->value('id_user_state');

        $this->user = User::create([
            'first_name'    => 'Tim',
            'last_name'     => 'Test',
            'email'         => 'tim@example.com',
            'password'      => Hash::make('password'),
            'id_role'       => $userRoleId,
            'id_user_state' => $activeId,
        ]);
    }

    private function authHeader(): array
    {
        $token = $this->user->createToken('test')->plainTextToken;
        return ['Authorization' => "Bearer $token"];
    }

    public function test_user_can_create_a_journal_entry(): void
    {
        $response = $this->withHeaders($this->authHeader())
            ->postJson('/api/journal', [
                'id_emotion' => $this->emotion->id_emotion,
                'entry_date' => now()->toDateString(),
                'note'       => 'Belle journée',
            ]);

        $response->assertCreated();
        $this->assertDatabaseHas('emotion_journal_entries', [
            'id_user'    => $this->user->id_user,
            'id_emotion' => $this->emotion->id_emotion,
        ]);
    }

    public function test_user_cannot_create_entry_in_the_future(): void
    {
        $response = $this->withHeaders($this->authHeader())
            ->postJson('/api/journal', [
                'id_emotion' => $this->emotion->id_emotion,
                'entry_date' => now()->addDays(3)->toDateString(),
            ]);

        $response->assertStatus(422);
    }

    public function test_user_can_list_their_journal_entries(): void
    {
        $this->withHeaders($this->authHeader())->postJson('/api/journal', [
            'id_emotion' => $this->emotion->id_emotion,
            'entry_date' => now()->toDateString(),
        ]);

        $response = $this->withHeaders($this->authHeader())->getJson('/api/journal');

        $response->assertOk();
        $response->assertJsonCount(1);
    }

    public function test_user_cannot_see_other_users_entries(): void
    {
        $userRoleId = Role::where('name', Role::USER)->value('id_role');
        $activeId   = UserState::where('name', UserState::ACTIVE)->value('id_user_state');

        $other = User::create([
            'first_name'    => 'Autre',
            'last_name'     => 'User',
            'email'         => 'autre@example.com',
            'password'      => Hash::make('password'),
            'id_role'       => $userRoleId,
            'id_user_state' => $activeId,
        ]);

        $this->withHeaders([
            'Authorization' => 'Bearer ' . $other->createToken('t')->plainTextToken,
        ])->postJson('/api/journal', [
            'id_emotion' => $this->emotion->id_emotion,
            'entry_date' => now()->toDateString(),
        ]);

        $response = $this->withHeaders($this->authHeader())->getJson('/api/journal');

        $response->assertOk();
        $response->assertJsonCount(0); // Tim ne voit pas l'entrée d'Autre
    }

    public function test_report_returns_aggregated_data(): void
    {
        $this->withHeaders($this->authHeader())->postJson('/api/journal', [
            'id_emotion' => $this->emotion->id_emotion,
            'entry_date' => now()->toDateString(),
        ]);

        $response = $this->withHeaders($this->authHeader())
            ->getJson('/api/journal/report?period=week');

        $response->assertOk();
        $response->assertJsonStructure([
            'from', 'to', 'total_entries',
            'by_category' => [['id_emotion_category', 'name', 'color_hex', 'count', 'percentage']],
        ]);
    }
}
