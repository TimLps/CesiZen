<?php

namespace Tests;

use Illuminate\Foundation\Testing\TestCase as BaseTestCase;

abstract class TestCase extends BaseTestCase
{
    /**
     * Oublie l'utilisateur déjà résolu par les guards d'authentification.
     *
     * Dans un test, plusieurs requêtes simulées partagent le même conteneur
     * applicatif. Le RequestGuard de Sanctum mémorise l'utilisateur qu'il a
     * résolu à la première requête et le réutilise pour les suivantes, quel
     * que soit le jeton envoyé ensuite. Sous php-fpm, chaque requête HTTP
     * démarre un conteneur neuf : ce cache n'existe pas. Appeler cette méthode
     * entre deux requêtes reproduit donc le comportement réel du serveur.
     */
    protected function forgetAuthenticatedUser(): void
    {
        $this->app['auth']->forgetGuards();
    }
}
