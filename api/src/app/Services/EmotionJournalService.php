<?php

namespace App\Services;

use App\Models\EmotionJournalEntry;
use App\Repositories\Interfaces\EmotionJournalRepositoryInterface;
use Carbon\Carbon;
use Illuminate\Database\Eloquent\Collection;
use Symfony\Component\HttpKernel\Exception\TooManyRequestsHttpException;

class EmotionJournalService
{
    /** Cooldown serveur entre deux saisies d'émotion par le même utilisateur. */
    public const COOLDOWN_SECONDS = 300; // 5 minutes

    public function __construct(
        private readonly EmotionJournalRepositoryInterface $repository,
    ) {}

    public function listForUser(int $userId, ?string $from = null, ?string $to = null): Collection
    {
        return $this->repository->listForUser($userId, $from, $to);
    }

    public function findForUser(int $entryId, int $userId): ?EmotionJournalEntry
    {
        return $this->repository->findByIdForUser($entryId, $userId);
    }

    /**
     * Crée une entrée de journal en respectant le cooldown 5 min côté serveur.
     *
     * - Le cooldown se base sur `created_at` de la dernière entrée (instant réel
     *   d'enregistrement), jamais sur `felt_at` qui peut être antidaté.
     * - Si l'utilisateur tente une création trop rapprochée, on lève une
     *   TooManyRequestsHttpException → réponse HTTP 429 avec header Retry-After.
     */
    public function create(int $userId, array $data): EmotionJournalEntry
    {
        $last = $this->repository->lastEntryFor($userId);
        if ($last && $last->created_at) {
            $elapsed = (int) floor($last->created_at->diffInSeconds(now(), absolute: true));
            if ($elapsed < self::COOLDOWN_SECONDS) {
                $retryAfter = self::COOLDOWN_SECONDS - $elapsed;
                $minutes    = intdiv($retryAfter, 60);
                $seconds    = $retryAfter % 60;
                $human = $minutes > 0
                    ? sprintf('%d min %02d s', $minutes, $seconds)
                    : sprintf('%d s', $seconds);
                throw new TooManyRequestsHttpException(
                    retryAfter: $retryAfter,
                    message: "Patientez encore {$human} avant une nouvelle saisie.",
                );
            }
        }

        $now = now();

        // felt_at par défaut = now() ; permet à l'utilisateur de déclarer un
        // ressenti antérieur via le payload (5/10/15/30/60 minutes plus tôt).
        $feltAt = isset($data['felt_at']) ? Carbon::parse($data['felt_at']) : $now;

        // entry_date est dérivée de felt_at pour que les rapports par jour
        // restent cohérents si l'on antidate (ex : ressenti hier soir, saisi ce matin).
        $entryDate = isset($data['entry_date'])
            ? Carbon::parse($data['entry_date'])->toDateString()
            : $feltAt->toDateString();

        $payload = [
            'id_user'    => $userId,
            'id_emotion' => $data['id_emotion'],
            'entry_date' => $entryDate,
            'felt_at'    => $feltAt,
            'note'       => $data['note'] ?? null,
        ];

        return $this->repository->create($payload);
    }

    public function update(EmotionJournalEntry $entry, array $data): EmotionJournalEntry
    {
        // Sur l'update on accepte également felt_at, mais on ne touche pas au cooldown
        // (qui ne concerne que la création).
        if (isset($data['felt_at'])) {
            $data['felt_at'] = Carbon::parse($data['felt_at']);
        }
        return $this->repository->update($entry, $data);
    }

    public function delete(EmotionJournalEntry $entry): bool
    {
        return $this->repository->delete($entry);
    }

    /**
     * Génère un rapport pour une période prédéfinie : week | month | quarter | year
     * ou pour une plage personnalisée [from, to].
     */
    public function getReport(int $userId, string $period = 'week', ?string $from = null, ?string $to = null): array
    {
        if ($from && $to) {
            return $this->repository->reportForPeriod($userId, $from, $to);
        }

        $now = Carbon::today();

        [$start, $end] = match ($period) {
            'week'    => [$now->copy()->subDays(6), $now],
            'month'   => [$now->copy()->subDays(29), $now],
            'quarter' => [$now->copy()->subDays(89), $now],
            'year'    => [$now->copy()->subDays(364), $now],
            default   => [$now->copy()->subDays(6), $now],
        };

        return $this->repository->reportForPeriod(
            $userId,
            $start->toDateString(),
            $end->toDateString(),
        );
    }

    /**
     * Top N catégories ressenties sur les `$hours` dernières heures.
     */
    public function topCategoriesLastHours(int $userId, int $hours = 24, int $limit = 3): array
    {
        return $this->repository->topCategoriesLastHours($userId, $hours, $limit);
    }
}
