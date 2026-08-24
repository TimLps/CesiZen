<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class UserResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id_user'        => $this->id_user,
            'first_name'     => $this->first_name,
            'last_name'      => $this->last_name,
            'full_name'      => $this->full_name,
            'email'          => $this->email,
            'city'           => $this->city,
            'birth_date'     => $this->birth_date?->toDateString(),
            'id_role'        => $this->id_role,
            'id_user_state'  => $this->id_user_state,
            'role'           => $this->whenLoaded('role', fn() => [
                'id_role' => $this->role->id_role,
                'name'    => $this->role->name,
                'label'   => $this->role->label,
            ]),
            'user_state'     => $this->whenLoaded('userState', fn() => [
                'id_user_state' => $this->userState->id_user_state,
                'name'          => $this->userState->name,
                'label'         => $this->userState->label,
            ]),
            'created_at'     => $this->created_at?->toIso8601String(),
            'updated_at'     => $this->updated_at?->toIso8601String(),
        ];
    }
}
