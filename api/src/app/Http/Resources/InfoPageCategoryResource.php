<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class InfoPageCategoryResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id_info_page_category' => $this->id_info_page_category,
            'name'        => $this->name,
            'slug'        => $this->slug,
            'icon'        => $this->icon,
            'color_hex'   => $this->color_hex,
            'sort_order'  => $this->sort_order,
            'is_active'   => $this->is_active,
            'pages_count' => $this->whenCounted('pages'),
            'pages'       => $this->whenLoaded(
                'pages',
                fn () => InfoPageResource::collection($this->pages),
            ),
        ];
    }
}
