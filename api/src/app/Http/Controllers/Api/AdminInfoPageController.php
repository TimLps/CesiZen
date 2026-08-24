<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Requests\InfoPage\InfoPageStoreRequest;
use App\Http\Requests\InfoPage\InfoPageUpdateRequest;
use App\Http\Resources\InfoPageResource;
use App\Services\InfoPageService;
use Illuminate\Http\JsonResponse;
use OpenApi\Attributes as OA;

class AdminInfoPageController extends Controller
{
    public function __construct(
        private readonly InfoPageService $service,
    ) {}

    #[OA\Get(
        path: '/api/admin/info-pages',
        summary: 'Liste complète des pages (publiées + brouillons)',
        tags: ['Admin - Informations'],
        security: [['bearerAuth' => []]],
        responses: [new OA\Response(response: 200, description: 'OK')]
    )]
    public function index(): JsonResponse
    {
        $pages = $this->service->getAllForAdmin();
        return response()->json(InfoPageResource::collection($pages));
    }

    #[OA\Get(
        path: '/api/admin/info-pages/{id}',
        summary: 'Détail d\'une page (admin)',
        tags: ['Admin - Informations'],
        security: [['bearerAuth' => []]],
        responses: [new OA\Response(response: 200, description: 'OK')]
    )]
    public function show(int $id): JsonResponse
    {
        $page = $this->service->findByIdOrSlug((string) $id);
        if (! $page) {
            return response()->json(['message' => 'Page introuvable.'], 404);
        }
        return response()->json(new InfoPageResource($page));
    }

    #[OA\Post(
        path: '/api/admin/info-pages',
        summary: 'Crée une page d\'information',
        tags: ['Admin - Informations'],
        security: [['bearerAuth' => []]],
        responses: [new OA\Response(response: 201, description: 'Créée')]
    )]
    public function store(InfoPageStoreRequest $request): JsonResponse
    {
        $data = $request->validated();
        // Audit : enregistre le modérateur qui crée la page.
        $data['created_by'] = $request->user()?->id_user;
        $data['updated_by'] = $request->user()?->id_user;
        $page = $this->service->create($data);
        return response()->json(new InfoPageResource($page), 201);
    }

    #[OA\Put(
        path: '/api/admin/info-pages/{id}',
        summary: 'Met à jour une page',
        tags: ['Admin - Informations'],
        security: [['bearerAuth' => []]],
        responses: [new OA\Response(response: 200, description: 'OK')]
    )]
    public function update(InfoPageUpdateRequest $request, int $id): JsonResponse
    {
        $page = $this->service->findByIdOrSlug((string) $id);
        if (! $page) {
            return response()->json(['message' => 'Page introuvable.'], 404);
        }
        $data = $request->validated();
        // Audit : enregistre le dernier modérateur qui touche au contenu.
        $data['updated_by'] = $request->user()?->id_user;
        $page = $this->service->update($page, $data);
        return response()->json(new InfoPageResource($page));
    }

    #[OA\Delete(
        path: '/api/admin/info-pages/{id}',
        summary: 'Supprime une page',
        tags: ['Admin - Informations'],
        security: [['bearerAuth' => []]],
        responses: [new OA\Response(response: 200, description: 'Supprimée')]
    )]
    public function destroy(int $id): JsonResponse
    {
        $page = $this->service->findByIdOrSlug((string) $id);
        if (! $page) {
            return response()->json(['message' => 'Page introuvable.'], 404);
        }
        $this->service->delete($page);
        return response()->json(['message' => 'Page supprimée.']);
    }
}
