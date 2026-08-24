<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Resources\InfoPageResource;
use App\Services\InfoPageService;
use Illuminate\Http\JsonResponse;
use OpenApi\Attributes as OA;

class InfoPageController extends Controller
{
    public function __construct(
        private readonly InfoPageService $service,
    ) {}

    #[OA\Get(
        path: '/api/info-pages',
        summary: 'Liste des pages d\'information publiées (menu public)',
        tags: ['Informations'],
        responses: [new OA\Response(response: 200, description: 'OK')]
    )]
    public function index(): JsonResponse
    {
        $pages = $this->service->getPublishedMenu();
        return response()->json(InfoPageResource::collection($pages));
    }

    #[OA\Get(
        path: '/api/info-pages/{idOrSlug}',
        summary: 'Détail d\'une page d\'information',
        tags: ['Informations'],
        responses: [
            new OA\Response(response: 200, description: 'Page'),
            new OA\Response(response: 404, description: 'Introuvable'),
        ]
    )]
    public function show(string $idOrSlug): JsonResponse
    {
        $page = $this->service->findByIdOrSlug($idOrSlug);
        if (! $page || ! $page->is_published) {
            return response()->json(['message' => 'Page introuvable.'], 404);
        }
        return response()->json(new InfoPageResource($page));
    }
}
