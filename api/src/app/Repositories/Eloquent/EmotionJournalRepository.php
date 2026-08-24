<?php

namespace App\Repositories\Eloquent;

use App\Models\EmotionJournalEntry;
use App\Repositories\Interfaces\EmotionJournalRepositoryInterface;
use Illuminate\Database\Eloquent\Collection;
use Illuminate\Support\Facades\DB;

class EmotionJournalRepository implements EmotionJournalRepositoryInterface
{
    public function listForUser(int $userId, ?string $from = null, ?string $to = null): Collection
    {
        $query = EmotionJournalEntry::with(['emotion.category'])
            ->where('id_user', $userId);

        if ($from) {
            $query->where('entry_date', '>=', $from);
        }

        if ($to) {
            $query->where('entry_date', '<=', $to);
        }

        return $query->orderBy('felt_at', 'desc')
            ->orderBy('entry_date', 'desc')
            ->orderBy('created_at', 'desc')
            ->get();
    }

    public function findByIdForUser(int $entryId, int $userId): ?EmotionJournalEntry
    {
        return EmotionJournalEntry::with(['emotion.category'])
            ->where('id_journal_entry', $entryId)
            ->where('id_user', $userId)
            ->first();
    }

    public function create(array $data): EmotionJournalEntry
    {
        $entry = EmotionJournalEntry::create($data);
        return $entry->fresh(['emotion.category']);
    }

    public function update(EmotionJournalEntry $entry, array $data): EmotionJournalEntry
    {
        $entry->update($data);
        return $entry->fresh(['emotion.category']);
    }

    public function delete(EmotionJournalEntry $entry): bool
    {
        return (bool) $entry->delete();
    }

    public function lastEntryFor(int $userId): ?EmotionJournalEntry
    {
        return EmotionJournalEntry::where('id_user', $userId)
            ->orderByDesc('created_at')
            ->first();
    }

    /**
     * Génère un rapport agrégé par catégorie d'émotion (niveau 1)
     * Retourne les pourcentages par catégorie sur la période demandée.
     */
    public function reportForPeriod(int $userId, string $from, string $to): array
    {
        $rows = DB::table('emotion_journal_entries as eje')
            ->join('emotions as e', 'e.id_emotion', '=', 'eje.id_emotion')
            ->join('emotion_categories as ec', 'ec.id_emotion_category', '=', 'e.id_emotion_category')
            ->where('eje.id_user', $userId)
            ->whereBetween('eje.entry_date', [$from, $to])
            ->select(
                'ec.id_emotion_category',
                'ec.name',
                'ec.feeling_label',
                'ec.color_hex',
                'ec.icon',
                DB::raw('COUNT(eje.id_journal_entry) as total')
            )
            ->groupBy('ec.id_emotion_category', 'ec.name', 'ec.feeling_label', 'ec.color_hex', 'ec.icon')
            ->orderByDesc('total')
            ->get();

        $totalEntries = $rows->sum('total');

        $byCategory = $rows->map(function ($row) use ($totalEntries) {
            return [
                'id_emotion_category' => $row->id_emotion_category,
                'name'                => $row->name,
                'feeling_label'       => $row->feeling_label,
                'color_hex'           => $row->color_hex,
                'icon'                => $row->icon,
                'count'               => (int) $row->total,
                'percentage'          => $totalEntries > 0
                    ? round(($row->total / $totalEntries) * 100, 1)
                    : 0,
            ];
        });

        return [
            'from'          => $from,
            'to'            => $to,
            'total_entries' => $totalEntries,
            'by_category'   => $byCategory->values()->all(),
        ];
    }

    /**
     * Top N catégories d'émotions sur les `$hours` dernières heures.
     *
     * On utilise COALESCE(felt_at, entry_date) pour rester compatible avec
     * d'éventuelles entrées historiques sans felt_at.
     */
    public function topCategoriesLastHours(int $userId, int $hours, int $limit): array
    {
        $since = now()->subHours($hours);

        $rows = DB::table('emotion_journal_entries as eje')
            ->join('emotions as e', 'e.id_emotion', '=', 'eje.id_emotion')
            ->join('emotion_categories as ec', 'ec.id_emotion_category', '=', 'e.id_emotion_category')
            ->where('eje.id_user', $userId)
            ->where(DB::raw('COALESCE(eje.felt_at, eje.entry_date)'), '>=', $since)
            ->select(
                'ec.id_emotion_category',
                'ec.name',
                'ec.feeling_label',
                'ec.color_hex',
                'ec.icon',
                DB::raw('COUNT(eje.id_journal_entry) as total')
            )
            ->groupBy('ec.id_emotion_category', 'ec.name', 'ec.feeling_label', 'ec.color_hex', 'ec.icon')
            ->orderByDesc('total')
            ->limit($limit)
            ->get();

        $totalEntries = $rows->sum('total');

        $byCategory = $rows->map(function ($row) use ($totalEntries) {
            return [
                'id_emotion_category' => $row->id_emotion_category,
                'name'                => $row->name,
                'feeling_label'       => $row->feeling_label,
                'color_hex'           => $row->color_hex,
                'icon'                => $row->icon,
                'count'               => (int) $row->total,
                'percentage'          => $totalEntries > 0
                    ? round(($row->total / $totalEntries) * 100, 1)
                    : 0,
            ];
        });

        return [
            'window_hours'  => $hours,
            'since'         => $since->toIso8601String(),
            'total_entries' => $totalEntries,
            'by_category'   => $byCategory->values()->all(),
        ];
    }
}
