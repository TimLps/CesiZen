<?php

namespace App\Http\Requests\Emotion;

use Illuminate\Foundation\Http\FormRequest;

class EmotionStoreRequest extends FormRequest
{
    public function authorize(): bool
    {
        return $this->user()?->isAdmin() ?? false;
    }

    public function rules(): array
    {
        return [
            'id_emotion_category' => ['required', 'integer', 'exists:emotion_categories,id_emotion_category'],
            'name'                => ['required', 'string', 'max:50'],
            'feeling_label'       => ['nullable', 'string', 'max:80'],
            'is_active'           => ['nullable', 'boolean'],
        ];
    }
}
