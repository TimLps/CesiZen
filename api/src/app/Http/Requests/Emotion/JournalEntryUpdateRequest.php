<?php

namespace App\Http\Requests\Emotion;

use Illuminate\Foundation\Http\FormRequest;

class JournalEntryUpdateRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'id_emotion' => ['sometimes', 'integer', 'exists:emotions,id_emotion'],
            'entry_date' => ['sometimes', 'date', 'before_or_equal:today'],
            'note'       => ['nullable', 'string', 'max:2000'],
        ];
    }
}
