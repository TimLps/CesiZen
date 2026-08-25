<?php

namespace App\Http\Requests\Admin;

use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Validation\Rules\Password;
use Illuminate\Validation\Rule;

class AdminUserUpdateRequest extends FormRequest
{
    public function authorize(): bool
    {
        return $this->user()->isAdmin();
    }

    public function rules(): array
    {
        $userId = $this->route('id');

        return [
            'first_name'    => ['sometimes', 'string', 'max:50'],
            'last_name'     => ['sometimes', 'string', 'max:50'],
            'email'         => ['sometimes', 'email', 'max:255', Rule::unique('users', 'email')->ignore($userId, 'id_user')],
            'password'      => ['sometimes', 'string', Password::defaults()],
            'city'          => ['nullable', 'string', 'max:100'],
            'birth_date'    => ['nullable', 'date'],
            'id_role'       => ['sometimes', 'integer', 'exists:roles,id_role'],
            'id_user_state' => ['sometimes', 'integer', 'exists:user_states,id_user_state'],
        ];
    }
}
