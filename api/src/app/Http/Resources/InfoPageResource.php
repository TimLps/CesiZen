<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class InfoPageResource extends JsonResource
{
    /**
     * Sérialise une page d'information.
     *
     * - Catégorie : exposée à tous (mobile + admin) pour la navigation par thème.
     * - created_by / updated_by : exposés UNIQUEMENT côté admin (pour identifier
     *   le modérateur responsable d'un contenu). Le mobile n'en a pas besoin.
     */
    public function toArray(Request $request): array
    {
        // L'admin est identifié par la présence du préfixe /admin dans la route,
        // ou par l'utilisateur authentifié ayant le rôle admin.
        $isAdminContext = str_starts_with($request->path(), 'api/admin')
            || ($request->user()?->isAdmin() ?? false);

        return [
            'id_info_page'          => $this->id_info_page,
            'slug'                  => $this->slug,
            'title'                 => $this->title,
            'menu_label'            => $this->menu_label,
            'content'               => $this->content,
            'id_info_page_category' => $this->id_info_page_category,
            'category'              => $this->whenLoaded(
                'category',
                fn () => new InfoPageCategoryResource($this->category),
            ),
            'sort_order'            => $this->sort_order,
            'is_published'          => $this->is_published,
            'created_at'            => $this->created_at?->toIso8601String(),
            'updated_at'            => $this->updated_at?->toIso8601String(),

            // Champs d'audit visibles uniquement côté admin
            'created_by'      => $this->when($isAdminContext, $this->created_by),
            'updated_by'      => $this->when($isAdminContext, $this->updated_by),
            'creator_name'    => $this->when(
                $isAdminContext && $this->relationLoaded('creator') && $this->creator,
                fn () => $this->creator->fullName ?? trim($this->creator->first_name . ' ' . $this->creator->last_name),
            ),
            'last_editor_name' => $this->when(
                $isAdminContext && $this->relationLoaded('lastEditor') && $this->lastEditor,
                fn () => $this->lastEditor->fullName ?? trim($this->lastEditor->first_name . ' ' . $this->lastEditor->last_name),
            ),
        ];
    }
}
