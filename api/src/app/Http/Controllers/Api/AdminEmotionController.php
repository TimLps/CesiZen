<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Requests\Emotion\EmotionStoreRequest;
use App\Http\Resources\EmotionCategoryResource;
use App\Http\Resources\EmotionResource;
use App\Models\Emotion;
use App\Models\EmotionCategory;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use OpenApi\Attributes as OA;

class AdminEmotionController extends Controller
{
    // ── Catégories (niveau 1) ────────────────────────────────────────────────

    #[OA\Get(
        path: '/api/admin/emotion-categories',
        summary: 'Liste complète des catégories (admin)',
        tags: ['Admin - Émotions'],
        security: [['bearerAuth' => []]]
    )]
    public function listCategories(): JsonResponse
    {
        $cats = EmotionCategory::with('emotions')->orderBy('sort_order')->get();
        return response()->json(EmotionCategoryResource::collection($cats));
    }

    #[OA\Post(
        path: '/api/admin/emotion-categories',
        summary: 'Crée une catégorie d\'émotion',
        tags: ['Admin - Émotions'],
        security: [['bearerAuth' => []]]
    )]
    public function storeCategory(Request $request): JsonResponse
    {
        $data = $request->validate([
            'name'          => ['required', 'string', 'max:50', 'unique:emotion_categories,name'],
            'feeling_label' => ['nullable', 'string', 'max:80'],
            'color_hex'     => ['required', 'string', 'regex:/^#[0-9A-Fa-f]{6}$/'],
            'icon'          => ['nullable', 'string', 'max:50'],
            'sort_order'    => ['nullable', 'integer', 'min:0'],
            'is_active'     => ['nullable', 'boolean'],
        ]);

        $cat = EmotionCategory::create($data);
        return response()->json(new EmotionCategoryResource($cat), 201);
    }

    #[OA\Put(
        path: '/api/admin/emotion-categories/{id}',
        summary: 'Met à jour une catégorie',
        tags: ['Admin - Émotions'],
        security: [['bearerAuth' => []]]
    )]
    public function updateCategory(Request $request, int $id): JsonResponse
    {
        $cat = EmotionCategory::find($id);
        if (! $cat) {
            return response()->json(['message' => 'Catégorie introuvable.'], 404);
        }

        $data = $request->validate([
            'name'          => ['sometimes', 'string', 'max:50', "unique:emotion_categories,name,{$id},id_emotion_category"],
            'feeling_label' => ['nullable', 'string', 'max:80'],
            'color_hex'     => ['sometimes', 'string', 'regex:/^#[0-9A-Fa-f]{6}$/'],
            'icon'          => ['nullable', 'string', 'max:50'],
            'sort_order'    => ['sometimes', 'integer', 'min:0'],
            'is_active'     => ['sometimes', 'boolean'],
        ]);

        $cat->update($data);
        return response()->json(new EmotionCategoryResource($cat->fresh('emotions')));
    }

    #[OA\Delete(
        path: '/api/admin/emotion-categories/{id}',
        summary: 'Supprime une catégorie (cascade sur les émotions niveau 2)',
        tags: ['Admin - Émotions'],
        security: [['bearerAuth' => []]]
    )]
    public function destroyCategory(int $id): JsonResponse
    {
        $cat = EmotionCategory::find($id);
        if (! $cat) {
            return response()->json(['message' => 'Catégorie introuvable.'], 404);
        }
        $cat->delete();
        return response()->json(['message' => 'Catégorie supprimée.']);
    }

    // ── Émotions (niveau 2) ──────────────────────────────────────────────────

    #[OA\Post(
        path: '/api/admin/emotions',
        summary: 'Crée une émotion (niveau 2)',
        tags: ['Admin - Émotions'],
        security: [['bearerAuth' => []]]
    )]
    public function storeEmotion(EmotionStoreRequest $request): JsonResponse
    {
        $emotion = Emotion::create($request->validated());
        return response()->json(new EmotionResource($emotion->load('category')), 201);
    }

    #[OA\Put(
        path: '/api/admin/emotions/{id}',
        summary: 'Met à jour une émotion',
        tags: ['Admin - Émotions'],
        security: [['bearerAuth' => []]]
    )]
    public function updateEmotion(Request $request, int $id): JsonResponse
    {
        $emotion = Emotion::find($id);
        if (! $emotion) {
            return response()->json(['message' => 'Émotion introuvable.'], 404);
        }

        $data = $request->validate([
            'id_emotion_category' => ['sometimes', 'integer', 'exists:emotion_categories,id_emotion_category'],
            'name'                => ['sometimes', 'string', 'max:50'],
            'feeling_label'       => ['nullable', 'string', 'max:80'],
            'is_active'           => ['sometimes', 'boolean'],
        ]);

        $emotion->update($data);
        return response()->json(new EmotionResource($emotion->fresh('category')));
    }

    #[OA\Delete(
        path: '/api/admin/emotions/{id}',
        summary: 'Supprime une émotion',
        tags: ['Admin - Émotions'],
        security: [['bearerAuth' => []]]
    )]
    public function destroyEmotion(int $id): JsonResponse
    {
        $emotion = Emotion::find($id);
        if (! $emotion) {
            return response()->json(['message' => 'Émotion introuvable.'], 404);
        }

        // Empêche la suppression si l'émotion est utilisée
        if ($emotion->journalEntries()->exists()) {
            // On désactive plutôt que de supprimer
            $emotion->update(['is_active' => false]);
            return response()->json([
                'message' => 'Émotion désactivée (déjà utilisée dans des journaux).',
            ]);
        }

        $emotion->delete();
        return response()->json(['message' => 'Émotion supprimée.']);
    }
}
