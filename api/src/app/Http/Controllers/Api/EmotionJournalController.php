<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Requests\Emotion\JournalEntryStoreRequest;
use App\Http\Requests\Emotion\JournalEntryUpdateRequest;
use App\Http\Resources\JournalEntryResource;
use App\Services\EmotionJournalService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use OpenApi\Attributes as OA;

class EmotionJournalController extends Controller
{
    public function __construct(
        private readonly EmotionJournalService $service,
    ) {}

    #[OA\Get(
        path: '/api/journal',
        summary: 'Journal de bord d\'émotions de l\'utilisateur connecté',
        tags: ['Journal d\'émotions'],
        security: [['bearerAuth' => []]],
        parameters: [
            new OA\Parameter(name: 'from', in: 'query', schema: new OA\Schema(type: 'string', format: 'date')),
            new OA\Parameter(name: 'to',   in: 'query', schema: new OA\Schema(type: 'string', format: 'date')),
        ],
        responses: [new OA\Response(response: 200, description: 'OK')]
    )]
    public function index(Request $request): JsonResponse
    {
        $entries = $this->service->listForUser(
            $request->user()->id_user,
            $request->query('from'),
            $request->query('to'),
        );

        return response()->json(JournalEntryResource::collection($entries));
    }

    #[OA\Get(
        path: '/api/journal/{id}',
        summary: 'Détail d\'une entrée',
        tags: ['Journal d\'émotions'],
        security: [['bearerAuth' => []]]
    )]
    public function show(Request $request, int $id): JsonResponse
    {
        $entry = $this->service->findForUser($id, $request->user()->id_user);
        if (! $entry) {
            return response()->json(['message' => 'Entrée introuvable.'], 404);
        }
        return response()->json(new JournalEntryResource($entry));
    }

    #[OA\Post(
        path: '/api/journal',
        summary: 'Ajoute une entrée au journal',
        description: 'Cooldown serveur de 5 minutes entre deux saisies du même utilisateur. '
            . 'En cas de violation, retourne HTTP 429 avec un header Retry-After.',
        tags: ['Journal d\'émotions'],
        security: [['bearerAuth' => []]],
        responses: [
            new OA\Response(response: 201, description: 'Entrée créée'),
            new OA\Response(response: 429, description: 'Cooldown 5 min non respecté'),
        ]
    )]
    public function store(JournalEntryStoreRequest $request): JsonResponse
    {
        $entry = $this->service->create(
            $request->user()->id_user,
            $request->validated(),
        );
        return response()->json(new JournalEntryResource($entry), 201);
    }

    #[OA\Get(
        path: '/api/journal/top-24h',
        summary: 'Top N catégories d\'émotions ressenties sur les 24 dernières heures',
        description: 'Utilisé par l\'écran d\'accueil mobile pour afficher un mini-rapport. '
            . 'Retourne le top 3 catégories niveau 1 par défaut, basé sur felt_at.',
        tags: ['Journal d\'émotions'],
        security: [['bearerAuth' => []]],
        parameters: [
            new OA\Parameter(name: 'limit', in: 'query', schema: new OA\Schema(type: 'integer', default: 3)),
        ]
    )]
    public function top24h(Request $request): JsonResponse
    {
        $limit = (int) $request->query('limit', 3);
        $limit = max(1, min(10, $limit));

        $report = $this->service->topCategoriesLastHours(
            $request->user()->id_user,
            hours: 24,
            limit: $limit,
        );

        return response()->json($report);
    }

    #[OA\Put(
        path: '/api/journal/{id}',
        summary: 'Met à jour une entrée',
        tags: ['Journal d\'émotions'],
        security: [['bearerAuth' => []]]
    )]
    public function update(JournalEntryUpdateRequest $request, int $id): JsonResponse
    {
        $entry = $this->service->findForUser($id, $request->user()->id_user);
        if (! $entry) {
            return response()->json(['message' => 'Entrée introuvable.'], 404);
        }
        $entry = $this->service->update($entry, $request->validated());
        return response()->json(new JournalEntryResource($entry));
    }

    #[OA\Delete(
        path: '/api/journal/{id}',
        summary: 'Supprime une entrée',
        tags: ['Journal d\'émotions'],
        security: [['bearerAuth' => []]]
    )]
    public function destroy(Request $request, int $id): JsonResponse
    {
        $entry = $this->service->findForUser($id, $request->user()->id_user);
        if (! $entry) {
            return response()->json(['message' => 'Entrée introuvable.'], 404);
        }
        $this->service->delete($entry);
        return response()->json(['message' => 'Entrée supprimée.']);
    }

    #[OA\Get(
        path: '/api/journal/report',
        summary: 'Rapport agrégé par catégorie d\'émotion',
        description: 'Période : week | month | quarter | year, ou plage personnalisée from/to',
        tags: ['Journal d\'émotions'],
        security: [['bearerAuth' => []]],
        parameters: [
            new OA\Parameter(name: 'period', in: 'query', schema: new OA\Schema(type: 'string', enum: ['week', 'month', 'quarter', 'year'])),
            new OA\Parameter(name: 'from',   in: 'query', schema: new OA\Schema(type: 'string', format: 'date')),
            new OA\Parameter(name: 'to',     in: 'query', schema: new OA\Schema(type: 'string', format: 'date')),
        ]
    )]
    public function report(Request $request): JsonResponse
    {
        $report = $this->service->getReport(
            $request->user()->id_user,
            $request->query('period', 'week'),
            $request->query('from'),
            $request->query('to'),
        );
        return response()->json($report);
    }
}
