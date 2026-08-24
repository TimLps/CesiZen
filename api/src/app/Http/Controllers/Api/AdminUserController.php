<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Requests\Admin\AdminUserStoreRequest;
use App\Http\Requests\Admin\AdminUserUpdateRequest;
use App\Http\Resources\UserResource;
use App\Services\UserService;
use Illuminate\Http\JsonResponse;
use OpenApi\Attributes as OA;

class AdminUserController extends Controller
{
    public function __construct(
        private readonly UserService $userService,
    ) {}

    #[OA\Get(
        path: '/api/admin/users',
        summary: 'Liste paginée des utilisateurs (admin)',
        tags: ['Admin - Utilisateurs'],
        security: [['bearerAuth' => []]],
        responses: [new OA\Response(response: 200, description: 'Liste paginée')]
    )]
    public function index(): JsonResponse
    {
        $paginator = $this->userService->listUsers(20);
        return response()->json([
            'data' => UserResource::collection($paginator->items()),
            'meta' => [
                'current_page' => $paginator->currentPage(),
                'last_page'    => $paginator->lastPage(),
                'per_page'     => $paginator->perPage(),
                'total'        => $paginator->total(),
            ],
        ]);
    }

    #[OA\Get(
        path: '/api/admin/users/{id}',
        summary: 'Détail d\'un utilisateur',
        tags: ['Admin - Utilisateurs'],
        security: [['bearerAuth' => []]],
        responses: [
            new OA\Response(response: 200, description: 'Utilisateur'),
            new OA\Response(response: 404, description: 'Introuvable'),
        ]
    )]
    public function show(int $id): JsonResponse
    {
        $user = $this->userService->findUser($id);
        if (! $user) {
            return response()->json(['message' => 'Utilisateur introuvable.'], 404);
        }
        return response()->json(new UserResource($user));
    }

    #[OA\Post(
        path: '/api/admin/users',
        summary: 'Crée un utilisateur (admin ou citoyen)',
        tags: ['Admin - Utilisateurs'],
        security: [['bearerAuth' => []]],
        responses: [new OA\Response(response: 201, description: 'Créé')]
    )]
    public function store(AdminUserStoreRequest $request): JsonResponse
    {
        $user = $this->userService->createByAdmin($request->validated());
        return response()->json(new UserResource($user), 201);
    }

    #[OA\Put(
        path: '/api/admin/users/{id}',
        summary: 'Met à jour un utilisateur',
        tags: ['Admin - Utilisateurs'],
        security: [['bearerAuth' => []]],
        responses: [new OA\Response(response: 200, description: 'OK')]
    )]
    public function update(AdminUserUpdateRequest $request, int $id): JsonResponse
    {
        $user = $this->userService->findUser($id);
        if (! $user) {
            return response()->json(['message' => 'Utilisateur introuvable.'], 404);
        }
        $updated = $this->userService->updateUser($user, $request->validated());
        return response()->json(new UserResource($updated));
    }

    #[OA\Patch(
        path: '/api/admin/users/{id}/deactivate',
        summary: 'Désactive un utilisateur (état: inactive)',
        tags: ['Admin - Utilisateurs'],
        security: [['bearerAuth' => []]],
        responses: [new OA\Response(response: 200, description: 'Désactivé')]
    )]
    public function deactivate(int $id): JsonResponse
    {
        $user = $this->userService->findUser($id);
        if (! $user) {
            return response()->json(['message' => 'Utilisateur introuvable.'], 404);
        }
        $user = $this->userService->deactivateUser($user);
        return response()->json(new UserResource($user));
    }

    #[OA\Delete(
        path: '/api/admin/users/{id}',
        summary: 'Soft-delete d\'un utilisateur',
        tags: ['Admin - Utilisateurs'],
        security: [['bearerAuth' => []]],
        responses: [new OA\Response(response: 200, description: 'Supprimé')]
    )]
    public function destroy(int $id): JsonResponse
    {
        $user = $this->userService->findUser($id);
        if (! $user) {
            return response()->json(['message' => 'Utilisateur introuvable.'], 404);
        }
        $this->userService->deleteUser($user);
        return response()->json(['message' => 'Utilisateur supprimé.']);
    }
}
