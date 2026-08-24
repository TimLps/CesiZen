<?php

namespace App\Http\Requests\InfoPage;

use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Validation\Rule;

class InfoPageUpdateRequest extends FormRequest
{
    public function authorize(): bool
    {
        return $this->user()?->isAdmin() ?? false;
    }

    public function rules(): array
    {
        $id = $this->route('id');

        return [
            'slug'                  => ['sometimes', 'string', 'max:100', Rule::unique('info_pages', 'slug')->ignore($id, 'id_info_page'), 'regex:/^[a-z0-9-]+$/'],
            'title'                 => ['sometimes', 'string', 'max:200'],
            'menu_label'            => ['sometimes', 'string', 'max:100'],
            'content'               => ['sometimes', 'string'],
            'id_info_page_category' => ['nullable', 'integer', 'exists:info_page_categories,id_info_page_category'],
            'sort_order'            => ['sometimes', 'integer', 'min:0'],
            'is_published'          => ['sometimes', 'boolean'],
        ];
    }
}
