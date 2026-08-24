<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class EmotionResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id_emotion'          => $this->id_emotion,
            'id_emotion_category' => $this->id_emotion_category,
            'name'                => $this->name,
            'feeling_label'       => $this->feeling_label,
            'is_active'           => $this->is_active,
            'category'            => $this->whenLoaded('category', fn() => new EmotionCategoryResource($this->category)),
        ];
    }
}
