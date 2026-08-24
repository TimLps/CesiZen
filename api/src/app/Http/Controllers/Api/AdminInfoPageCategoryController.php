<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Resources\InfoPageCategoryResource;
use App\Models\InfoPageCategory;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use OpenApi\Attributes as OA;

class AdminInfoPageCategoryController extends Controller
{
    #[OA\Get(
        path: '/api/admin/info-page-categories',
        summary: 'Liste complète des thèmes d\'articles',
        tags: ['Admin - Informations'],
        security: [['bearerAuth' => []]],
        responses: [new OA\Response(response: 200, description: 'OK')]
    )]
    public function index(): JsonResponse
    {
        $categories = InfoPageCategory::withCount('pages')
            ->orderBy('sort_order')
            ->orderBy('name')
            ->get();
        return response()->json(InfoPageCategoryResource::collection($categories));
    }

    #[OA\Post(
        path: '/api/admin/info-page-categories',
        summary: 'Crée un thème',
        tags: ['Admin - Informations'],
        security: [['bearerAuth' => []]]
    )]
    public function store(Request $request): JsonResponse
    {
        $data = $request->validate([
            'name'       => ['required', 'string', 'max:100', 'unique:info_page_categories,name'],
            'slug'       => ['required', 'string', 'max:100', 'unique:info_page_categories,slug', 'regex:/^[a-z0-9-]+$/'],
            'icon'       => ['nullable', 'string', 'max:50'],
            'color_hex'  => ['nullable', 'string', 'regex:/^#[0-9A-Fa-f]{6}$/'],
            'sort_order' => ['nullable', 'integer', 'min:0'],
            'is_active'  => ['nullable', 'boolean'],
        ]);
        $cat = InfoPageCategory::create($data);
        return response()->json(new InfoPageCategoryResource($cat), 201);
    }

    #[OA\Put(
        path: '/api/admin/info-page-categories/{id}',
        summary: 'Met à jour un thème',
        tags: ['Admin - Informations'],
        security: [['bearerAuth' => []]]
    )]
    public function update(Request $request, int $id): JsonResponse
    {
        $cat = InfoPageCategory::find($id);
        if (! $cat) {
            return response()->json(['message' => 'Thème introuvable.'], 404);
        }
        $data = $request->validate([
            'name'       => ['sometimes', 'string', 'max:100', "unique:info_page_categories,name,{$id},id_info_page_category"],
            'slug'       => ['sometimes', 'string', 'max:100', "unique:info_page_categories,slug,{$id},id_info_page_category", 'regex:/^[a-z0-9-]+$/'],
            'icon'       => ['nullable', 'string', 'max:50'],
            'color_hex'  => ['nullable', 'string', 'regex:/^#[0-9A-Fa-f]{6}$/'],
            'sort_order' => ['sometimes', 'integer', 'min:0'],
            'is_active'  => ['sometimes', 'boolean'],
        ]);
        $cat->update($data);
        return response()->json(new InfoPageCategoryResource($cat->fresh()));
    }

    #[OA\Delete(
        path: '/api/admin/info-page-categories/{id}',
        summary: 'Supprime un thème (les articles liés deviennent sans catégorie)',
        tags: ['Admin - Informations'],
        security: [['bearerAuth' => []]]
    )]
    public function destroy(int $id): JsonResponse
    {
        $cat = InfoPageCategory::find($id);
        if (! $cat) {
            return response()->json(['message' => 'Thème introuvable.'], 404);
        }
        $cat->delete();
        return response()->json(['message' => 'Thème supprimé.']);
    }
}
