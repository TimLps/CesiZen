<?php

namespace App\Services;

use App\Models\InfoPage;
use App\Repositories\Interfaces\InfoPageRepositoryInterface;
use Illuminate\Database\Eloquent\Collection;

class InfoPageService
{
    public function __construct(
        private readonly InfoPageRepositoryInterface $repository,
    ) {}

    public function getPublishedMenu(): Collection
    {
        return $this->repository->allPublished();
    }

    public function getAllForAdmin(): Collection
    {
        return $this->repository->allForAdmin();
    }

    public function findByIdOrSlug(string $idOrSlug): ?InfoPage
    {
        if (is_numeric($idOrSlug)) {
            return $this->repository->findById((int) $idOrSlug);
        }
        return $this->repository->findBySlug($idOrSlug);
    }

    public function create(array $data): InfoPage
    {
        return $this->repository->create($data);
    }

    public function update(InfoPage $page, array $data): InfoPage
    {
        return $this->repository->update($page, $data);
    }

    public function delete(InfoPage $page): bool
    {
        return $this->repository->delete($page);
    }
}
