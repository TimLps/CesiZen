<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Resources\EmotionCategoryResource;
use App\Models\EmotionCategory;
use Illuminate\Http\JsonResponse;
use OpenApi\Attributes as OA;

class EmotionCategoryController extends Controller
{
    #[OA\Get(
        path: '/api/emotion-categories',
        summary: 'Liste des catégories d\'émotions de base (niveau 1) avec leurs émotions niveau 2',
        tags: ['Émotions'],
        security: [['bearerAuth' => []]],
        responses: [new OA\Response(response: 200, description: 'OK')]
    )]
    public function index(): JsonResponse
    {
        $categories = EmotionCategory::with(['emotions' => function ($q) {
            $q->where('is_active', true)->orderBy('name');
        }])
            ->where('is_active', true)
            ->orderBy('sort_order')
            ->get();

        return response()->json(EmotionCategoryResource::collection($categories));
    }
}
