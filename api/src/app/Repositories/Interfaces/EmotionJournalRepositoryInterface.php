<?php

namespace App\Repositories\Interfaces;

use App\Models\EmotionJournalEntry;
use Illuminate\Database\Eloquent\Collection;

interface EmotionJournalRepositoryInterface
{
    public function listForUser(int $userId, ?string $from = null, ?string $to = null): Collection;

    public function findByIdForUser(int $entryId, int $userId): ?EmotionJournalEntry;

    public function create(array $data): EmotionJournalEntry;

    public function update(EmotionJournalEntry $entry, array $data): EmotionJournalEntry;

    public function delete(EmotionJournalEntry $entry): bool;

    public function reportForPeriod(int $userId, string $from, string $to): array;

    /**
     * Retourne la dernière entrée de l'utilisateur (par created_at) ou null.
     * Sert au check de cooldown 5 min.
     */
    public function lastEntryFor(int $userId): ?EmotionJournalEntry;

    /**
     * Retourne les top N catégories d'émotions ressenties sur les dernières heures
     * (basé sur felt_at avec fallback entry_date), triées par fréquence.
     *
     * Format de sortie identique à reportForPeriod() : tableau by_category + total.
     */
    public function topCategoriesLastHours(int $userId, int $hours, int $limit): array;
}
