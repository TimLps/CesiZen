<?php

namespace App\Http\Requests\InfoPage;

use Illuminate\Foundation\Http\FormRequest;

class InfoPageStoreRequest extends FormRequest
{
    public function authorize(): bool
    {
        return $this->user()?->isAdmin() ?? false;
    }

    public function rules(): array
    {
        return [
            'slug'                  => ['required', 'string', 'max:100', 'unique:info_pages,slug', 'regex:/^[a-z0-9-]+$/'],
            'title'                 => ['required', 'string', 'max:200'],
            'menu_label'            => ['required', 'string', 'max:100'],
            'content'               => ['required', 'string'],
            'id_info_page_category' => ['nullable', 'integer', 'exists:info_page_categories,id_info_page_category'],
            'sort_order'            => ['nullable', 'integer', 'min:0'],
            'is_published'          => ['nullable', 'boolean'],
        ];
    }

    public function messages(): array
    {
        return [
            'slug.regex' => 'Le slug doit contenir uniquement des lettres minuscules, chiffres et tirets.',
        ];
    }
}
