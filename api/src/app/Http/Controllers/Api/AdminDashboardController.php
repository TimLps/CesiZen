<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Emotion;
use App\Models\EmotionCategory;
use App\Models\EmotionJournalEntry;
use App\Models\InfoPage;
use App\Models\User;
use App\Models\UserState;
use Illuminate\Http\JsonResponse;
use Illuminate\Support\Facades\DB;
use OpenApi\Attributes as OA;

class AdminDashboardController extends Controller
{
    #[OA\Get(
        path: '/api/admin/dashboard',
        summary: 'KPIs et statistiques du tableau de bord administrateur',
        tags: ['Admin - Dashboard'],
        security: [['bearerAuth' => []]],
        responses: [new OA\Response(response: 200, description: 'KPIs et stats agrégés')]
    )]
    public function index(): JsonResponse
    {
        $activeStateId = UserState::where('name', UserState::ACTIVE)->value('id_user_state');

        // Top 5 catégories d'émotions les plus saisies
        $topCategories = EmotionJournalEntry::query()
            ->join('emotions', 'emotions.id_emotion', '=', 'emotion_journal_entries.id_emotion')
            ->join('emotion_categories', 'emotion_categories.id_emotion_category', '=', 'emotions.id_emotion_category')
            ->select('emotion_categories.name', 'emotion_categories.color_hex', DB::raw('COUNT(*) as total'))
            ->groupBy('emotion_categories.id_emotion_category', 'emotion_categories.name', 'emotion_categories.color_hex')
            ->orderByDesc('total')
            ->limit(6)
            ->get();

        // Activité journal sur les 14 derniers jours (pour graphique évolution)
        $journalDaily = EmotionJournalEntry::query()
            ->select(DB::raw('DATE(entry_date) as day'), DB::raw('COUNT(*) as total'))
            ->where('entry_date', '>=', now()->subDays(14)->startOfDay())
            ->groupBy('day')
            ->orderBy('day')
            ->get();

        return response()->json([
            'users' => [
                'total'        => User::count(),
                'active'       => User::where('id_user_state', $activeStateId)->count(),
                'last_30_days' => User::where('created_at', '>=', now()->subDays(30))->count(),
                'last_7_days'  => User::where('created_at', '>=', now()->subDays(7))->count(),
            ],
            'info_pages' => [
                'total'     => InfoPage::count(),
                'published' => InfoPage::where('is_published', true)->count(),
                'drafts'    => InfoPage::where('is_published', false)->count(),
            ],
            'emotions' => [
                'categories' => EmotionCategory::count(),
                'emotions'   => Emotion::count(),
            ],
            'journal' => [
                'total_entries' => EmotionJournalEntry::count(),
                'last_7_days'   => EmotionJournalEntry::where('entry_date', '>=', now()->subDays(7))->count(),
                'last_30_days'  => EmotionJournalEntry::where('entry_date', '>=', now()->subDays(30))->count(),
                'top_categories' => $topCategories,
                'daily_14d'      => $journalDaily,
            ],
        ]);
    }
}
