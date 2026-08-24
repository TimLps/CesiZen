<?php

namespace App\Repositories\Eloquent;

use App\Models\InfoPage;
use App\Repositories\Interfaces\InfoPageRepositoryInterface;
use Illuminate\Database\Eloquent\Collection;

class InfoPageRepository implements InfoPageRepositoryInterface
{
    public function allPublished(): Collection
    {
        return InfoPage::published()
            ->with('category')
            ->orderBy('sort_order')
            ->orderBy('title')
            ->get();
    }

    public function allForAdmin(): Collection
    {
        return InfoPage::with(['category', 'creator', 'lastEditor'])
            ->orderBy('sort_order')
            ->orderBy('title')
            ->get();
    }

    public function findById(int $id): ?InfoPage
    {
        return InfoPage::with(['category', 'creator', 'lastEditor'])->find($id);
    }

    public function findBySlug(string $slug): ?InfoPage
    {
        return InfoPage::with('category')->where('slug', $slug)->first();
    }

    public function create(array $data): InfoPage
    {
        $page = InfoPage::create($data);
        return $page->fresh(['category', 'creator', 'lastEditor']);
    }

    public function update(InfoPage $page, array $data): InfoPage
    {
        $page->update($data);
        return $page->fresh(['category', 'creator', 'lastEditor']);
    }

    public function delete(InfoPage $page): bool
    {
        return (bool) $page->delete();
    }
}
