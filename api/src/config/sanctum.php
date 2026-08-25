<?php

return [
    /*
    | Domaines pour lesquels Sanctum accepterait une authentification par
    | cookie de session. La liste est volontairement vide : l'application
    | n'active pas ce mode (voir bootstrap/app.php). Elle mentionnait
    | notamment localhost:8081, port d'un service phpMyAdmin retiré de la
    | stack — un domaine déclaré ici obtient la session, il n'y a donc pas
    | lieu d'en laisser traîner.
    */
    'stateful' => array_filter(explode(',', (string) env('SANCTUM_STATEFUL_DOMAINS', ''))),

    'guard' => ['web'],
    'expiration' => null,
    'token_prefix' => env('SANCTUM_TOKEN_PREFIX', ''),
    'middleware' => [
        'authenticate_session' => Laravel\Sanctum\Http\Middleware\AuthenticateSession::class,
        'encrypt_cookies' => Illuminate\Cookie\Middleware\EncryptCookies::class,
        'validate_csrf_token' => Illuminate\Foundation\Http\Middleware\ValidateCsrfToken::class,
    ],
];
