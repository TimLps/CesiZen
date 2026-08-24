<?php

namespace App\Services;

use App\Models\Role;
use App\Models\User;
use App\Models\UserState;
use App\Repositories\Interfaces\UserRepositoryInterface;
use Illuminate\Contracts\Pagination\LengthAwarePaginator;

class UserService
{
    public function __construct(
        private readonly UserRepositoryInterface $userRepository,
    ) {}

    public function listUsers(int $perPage = 20): LengthAwarePaginator
    {
        return $this->userRepository->paginate($perPage);
    }

    public function findUser(int $id): ?User
    {
        return $this->userRepository->findById($id);
    }

    /**
     * Inscription d'un utilisateur standard (rôle "user", état "active").
     */
    public function registerUser(array $data): User
    {
        $data['id_role']       = $this->getRoleId(Role::USER);
        $data['id_user_state'] = $this->getActiveStateId();

        return $this->userRepository->create($data)->load(['role', 'userState']);
    }

    /**
     * Création d'un utilisateur par un admin (rôle/état au choix).
     */
    public function createByAdmin(array $data): User
    {
        if (empty($data['id_user_state'])) {
            $data['id_user_state'] = $this->getActiveStateId();
        }

        return $this->userRepository->create($data)->load(['role', 'userState']);
    }

    public function updateUser(User $user, array $data): User
    {
        return $this->userRepository->update($user, $data);
    }

    /**
     * Mise à jour de profil — un user ne peut pas modifier son rôle ou état.
     */
    public function updateProfile(User $user, array $data): User
    {
        unset($data['id_role'], $data['id_user_state']);

        return $this->userRepository->update($user, $data);
    }

    public function deactivateUser(User $user): User
    {
        return $this->userRepository->update($user, [
            'id_user_state' => $this->getStateId(UserState::INACTIVE),
        ]);
    }

    public function deleteUser(User $user): bool
    {
        // SoftDelete via le trait du modèle
        return $this->userRepository->delete($user);
    }

    // ── Helpers internes ──────────────────────────────────────────────────────

    private function getRoleId(string $name): int
    {
        return Role::where('name', $name)->value('id_role')
            ?? throw new \RuntimeException("Rôle '{$name}' introuvable.");
    }

    private function getStateId(string $name): int
    {
        return UserState::where('name', $name)->value('id_user_state')
            ?? throw new \RuntimeException("État '{$name}' introuvable.");
    }

    private function getActiveStateId(): int
    {
        return $this->getStateId(UserState::ACTIVE);
    }
}
