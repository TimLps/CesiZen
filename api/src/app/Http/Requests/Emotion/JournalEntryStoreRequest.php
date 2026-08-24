<?php

namespace App\Http\Requests\Emotion;

use Illuminate\Foundation\Http\FormRequest;

class JournalEntryStoreRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'id_emotion' => ['required', 'integer', 'exists:emotions,id_emotion'],
            // entry_date est désormais facultatif : si non fournie, on la dérive de felt_at.
            'entry_date' => ['nullable', 'date', 'before_or_equal:today'],
            // felt_at : moment réel du ressenti, antérieur à maintenant ; max 24 h dans le passé.
            'felt_at'    => ['nullable', 'date', 'before_or_equal:now', 'after:-25 hours'],
            'note'       => ['nullable', 'string', 'max:2000'],
        ];
    }

    public function messages(): array
    {
        return [
            'entry_date.before_or_equal' => 'La date ne peut pas être dans le futur.',
            'felt_at.before_or_equal'    => 'Le moment du ressenti ne peut pas être dans le futur.',
            'felt_at.after'              => 'Le ressenti doit dater de moins de 24 heures.',
        ];
    }
}
