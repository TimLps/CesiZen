<?php

namespace App\Repositories\Interfaces;

use App\Models\InfoPage;
use Illuminate\Database\Eloquent\Collection;

interface InfoPageRepositoryInterface
{
    public function allPublished(): Collection;

    public function allForAdmin(): Collection;

    public function findById(int $id): ?InfoPage;

    public function findBySlug(string $slug): ?InfoPage;

    public function create(array $data): InfoPage;

    public function update(InfoPage $page, array $data): InfoPage;

    public function delete(InfoPage $page): bool;
}
