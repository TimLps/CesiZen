<?php

return [

    'paths' => ['api/*', 'sanctum/csrf-cookie'],

    /*
    | Origines autorisées à appeler l'API depuis un navigateur.
    |
    | Seul le back-office est concerné : c'est la seule application web du
    | projet. L'application mobile est native, elle n'envoie pas d'en-tête
    | Origin et n'est donc pas soumise à la politique CORS — la restreindre
    | ici ne l'empêche pas de fonctionner.
    |
    | Le back-office Flutter Web doit être lancé sur un port fixe :
    |     flutter run -d chrome --web-port=3000
    | Sans --web-port, Flutter choisit un port au hasard à chaque démarrage,
    | qui ne correspondra à aucune des origines déclarées ci-dessous.
    */
    'allowed_origins' => [
        'http://localhost:3000',
        'http://127.0.0.1:3000',
    ],

    'allowed_origins_patterns' => [],

    'allowed_methods' => ['GET', 'POST', 'PUT', 'PATCH', 'DELETE', 'OPTIONS'],

    'allowed_headers' => ['Accept', 'Authorization', 'Content-Type', 'X-Requested-With'],

    'exposed_headers' => [],

    'max_age' => 3600,

    /*
    | L'authentification passe par un jeton Bearer porté par l'en-tête
    | Authorization, jamais par un cookie de session : le navigateur n'a
    | donc pas à joindre d'identifiants aux requêtes cross-origin.
    */
    'supports_credentials' => false,

];
