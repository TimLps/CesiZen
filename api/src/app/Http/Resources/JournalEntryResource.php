<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class JournalEntryResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id_journal_entry' => $this->id_journal_entry,
            'id_user'          => $this->id_user,
            'id_emotion'       => $this->id_emotion,
            'entry_date'       => $this->entry_date?->toDateString(),
            'felt_at'          => $this->felt_at?->toIso8601String(),
            'note'             => $this->note,
            'emotion'          => $this->whenLoaded('emotion', fn() => new EmotionResource($this->emotion)),
            'created_at'       => $this->created_at?->toIso8601String(),
            'updated_at'       => $this->updated_at?->toIso8601String(),
        ];
    }
}
