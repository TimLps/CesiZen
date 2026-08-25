<?php

namespace App\Providers;

use Illuminate\Cache\RateLimiting\Limit;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\RateLimiter;
use Illuminate\Support\ServiceProvider;

class AppServiceProvider extends ServiceProvider
{
    public function register(): void
    {
        //
    }

    public function boot(): void
    {
        $this->configureRateLimiting();
    }

    /**
     * Laravel 11 a retiré la limitation de débit par défaut du groupe de
     * middleware "api" : sans déclaration explicite, aucune route n'est
     * limitée. Deux limiteurs sont définis ici.
     */
    private function configureRateLimiting(): void
    {
        // Plafond général de l'API. Compté par utilisateur authentifié quand
        // c'est possible, sinon par adresse IP : deux utilisateurs derrière
        // une même sortie réseau ne se partagent pas le quota.
        RateLimiter::for('api', fn (Request $request) => Limit::perMinute(60)
            ->by($request->user()?->id_user ?: $request->ip()));

        // Routes d'authentification, ouvertes sans jeton. 5 tentatives par
        // minute et par adresse IP : un utilisateur qui se trompe de mot de
        // passe réessaie deux ou trois fois, pas six. Côté attaquant, le
        // plafond ramène une attaque par force brute à 7 200 essais par jour.
        RateLimiter::for('auth', fn (Request $request) => Limit::perMinute(5)
            ->by($request->ip()));
    }
}
