<?php

namespace App\Http\Requests\Admin;

use Illuminate\Foundation\Http\FormRequest;

class AdminUserStoreRequest extends FormRequest
{
    public function authorize(): bool
    {
        return $this->user()->isAdmin();
    }

    public function rules(): array
    {
        return [
            'first_name'    => ['required', 'string', 'max:50'],
            'last_name'     => ['required', 'string', 'max:50'],
            'email'         => ['required', 'email', 'max:255', 'unique:users,email'],
            'password'      => ['required', 'string', 'min:8'],
            'city'          => ['nullable', 'string', 'max:100'],
            'birth_date'    => ['nullable', 'date'],
            'id_role'       => ['required', 'integer', 'exists:roles,id_role'],
            'id_user_state' => ['nullable', 'integer', 'exists:user_states,id_user_state'],
        ];
    }
}
