<?php

namespace App\Repositories\Eloquent;

use App\Models\User;
use App\Repositories\Interfaces\UserRepositoryInterface;
use Illuminate\Contracts\Pagination\LengthAwarePaginator;

class UserRepository implements UserRepositoryInterface
{
    public function paginate(int $perPage = 20): LengthAwarePaginator
    {
        return User::with(['role', 'userState'])
            ->orderBy('created_at', 'desc')
            ->paginate($perPage);
    }

    public function findById(int $id): ?User
    {
        return User::with(['role', 'userState'])->find($id);
    }

    public function findByEmail(string $email): ?User
    {
        return User::with(['role', 'userState'])->where('email', $email)->first();
    }

    public function create(array $data): User
    {
        return User::create($data);
    }

    public function update(User $user, array $data): User
    {
        $user->update($data);
        return $user->fresh(['role', 'userState']);
    }

    public function delete(User $user): bool
    {
        return (bool) $user->delete();
    }
}
