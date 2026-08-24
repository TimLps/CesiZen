<?php

namespace App\Http\Requests\Profile;

use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Validation\Rule;

class UpdateProfileRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        $userId = $this->user()->id_user;

        return [
            'first_name' => ['sometimes', 'string', 'max:50'],
            'last_name'  => ['sometimes', 'string', 'max:50'],
            'email'      => ['sometimes', 'email', 'max:255', Rule::unique('users', 'email')->ignore($userId, 'id_user')],
            'city'       => ['nullable', 'string', 'max:100'],
            'birth_date' => ['nullable', 'date', 'before:today'],
            'password'   => ['sometimes', 'string', 'min:8', 'confirmed'],
        ];
    }
}
