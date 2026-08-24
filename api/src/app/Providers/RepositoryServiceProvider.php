<?php

namespace App\Providers;

use App\Repositories\Eloquent\EmotionJournalRepository;
use App\Repositories\Eloquent\InfoPageRepository;
use App\Repositories\Eloquent\UserRepository;
use App\Repositories\Interfaces\EmotionJournalRepositoryInterface;
use App\Repositories\Interfaces\InfoPageRepositoryInterface;
use App\Repositories\Interfaces\UserRepositoryInterface;
use Illuminate\Support\ServiceProvider;

class RepositoryServiceProvider extends ServiceProvider
{
    /**
     * Liaisons Interface → Implémentation Eloquent
     */
    public array $bindings = [
        UserRepositoryInterface::class           => UserRepository::class,
        InfoPageRepositoryInterface::class       => InfoPageRepository::class,
        EmotionJournalRepositoryInterface::class => EmotionJournalRepository::class,
    ];

    public function register(): void
    {
        //
    }

    public function boot(): void
    {
        //
    }
}
