<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Resources\InfoPageCategoryResource;
use App\Models\InfoPageCategory;
use Illuminate\Http\JsonResponse;
use OpenApi\Attributes as OA;

class InfoPageCategoryController extends Controller
{
    #[OA\Get(
        path: '/api/info-page-categories',
        summary: 'Liste des thèmes d\'articles avec les pages publiées de chaque thème',
        tags: ['Informations'],
        responses: [new OA\Response(response: 200, description: 'OK')]
    )]
    public function index(): JsonResponse
    {
        $categories = InfoPageCategory::query()
            ->where('is_active', true)
            ->with(['pages' => function ($q) {
                $q->where('is_published', true)
                  ->orderBy('sort_order')
                  ->orderBy('title');
            }])
            ->withCount(['pages as published_pages_count' => function ($q) {
                $q->where('is_published', true);
            }])
            ->orderBy('sort_order')
            ->orderBy('name')
            ->get();

        return response()->json(InfoPageCategoryResource::collection($categories));
    }
}
