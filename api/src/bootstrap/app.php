<?php

use App\Http\Middleware\RoleMiddleware;
use Illuminate\Foundation\Application;
use Illuminate\Http\Request;
use Illuminate\Foundation\Configuration\Exceptions;
use Illuminate\Foundation\Configuration\Middleware;

return Application::configure(basePath: dirname(__DIR__))
    ->withRouting(
        web: __DIR__.'/../routes/web.php',
        api: __DIR__.'/../routes/api.php',
        commands: __DIR__.'/../routes/console.php',
        health: '/up',
    )
    ->withMiddleware(function (Middleware $middleware) {
        // Register custom middleware aliases
        $middleware->alias([
            'role' => RoleMiddleware::class,
        ]);

        // Sanctum: stateful API guard for SPA back-office
        $middleware->statefulApi();

        // CESIZen n'expose aucune page de connexion : c'est une API, ses
        // clients sont l'application Flutter et le back-office. Sans cette
        // ligne, le middleware d'authentification construit son exception en
        // appelant route('login'), route qui n'existe pas : Laravel lève
        // RouteNotFoundException et répond 500 au lieu de 401. La redirection
        // pour visiteur anonyme est donc désactivée, ce qui laisse le
        // gestionnaire d'exceptions produire la réponse 401 attendue.
        $middleware->redirectGuestsTo(fn () => null);

        // Applique le limiteur "api" à toutes les routes du groupe.
        $middleware->throttleApi();
    })
    ->withExceptions(function (Exceptions $exceptions) {
        // Sans cela, une requête non authentifiée qui n'annonce pas
        // Accept: application/json déclenche une redirection vers une route
        // nommée "login", absente d'une application purement API : Laravel
        // lève alors RouteNotFoundException et répond 500 au lieu de 401.
        // La réponse 500 est doublement problématique : elle masque le
        // contrôle d'accès, et en environnement de développement elle expose
        // la trace d'exécution complète, chemins de fichiers compris.
        $exceptions->shouldRenderJsonWhen(
            fn (Request $request) => $request->is('api/*') || $request->expectsJson()
        );
    })->create();
