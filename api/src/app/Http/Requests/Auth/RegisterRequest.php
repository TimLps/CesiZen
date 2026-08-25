<?php

namespace App\Http\Requests\Auth;

use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Validation\Rules\Password;

class RegisterRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'first_name' => ['required', 'string', 'max:50'],
            'last_name'  => ['required', 'string', 'max:50'],
            'email'      => ['required', 'email', 'max:255', 'unique:users,email'],
            'password'   => ['required', 'string', Password::defaults(), 'confirmed'],
            'city'       => ['nullable', 'string', 'max:100'],
            'birth_date' => ['nullable', 'date', 'before:today'],
        ];
    }

    public function messages(): array
    {
        return [
            'email.unique'     => 'Cet email est déjà utilisé.',
            'password.min'     => 'Le mot de passe doit contenir au moins 12 caractères.',
            'password.confirmed' => 'La confirmation du mot de passe ne correspond pas.',
            'birth_date.before' => 'La date de naissance doit être antérieure à aujourd\'hui.',
        ];
    }
}
