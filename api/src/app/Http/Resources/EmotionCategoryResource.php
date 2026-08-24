<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class EmotionCategoryResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id_emotion_category' => $this->id_emotion_category,
            'name'                => $this->name,
            'feeling_label'       => $this->feeling_label,
            'color_hex'           => $this->color_hex,
            'icon'                => $this->icon,
            'sort_order'          => $this->sort_order,
            'is_active'           => $this->is_active,
            'emotions'            => $this->whenLoaded('emotions', fn() => EmotionResource::collection($this->emotions)),
        ];
    }
}
