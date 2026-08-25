<?php

return [

    // Pas de 'sanctum/csrf-cookie' : l'authentification par session n'est pas activée.
    'paths' => ['api/*'],

    /*
    | Origines autorisées à appeler l'API depuis un navigateur.
    |
    | Seul le back-office est concerné : c'est la seule application web du
    | projet. L'application mobile est native, elle n'envoie pas d'en-tête
    | Origin et n'est donc pas soumise à la politique CORS — la restreindre
    | ici ne l'empêche pas de fonctionner.
    |
    | Deux applications web, donc deux ports fixes : le back-office sur 3000,
    | l'application mobile lancée sur Chrome sur 3001. Elles doivent démarrer
    | avec --web-port, sans quoi Flutter choisit un port au hasard à chaque
    | lancement, qui ne correspondra à aucune origine déclarée ici.
    |
    |     cd backoffice && flutter run -d chrome --web-port=3000
    |     cd mobile     && flutter run -d chrome --web-port=3001
    */
    'allowed_origins' => [
        'http://localhost:3000',
        'http://127.0.0.1:3000',
        'http://localhost:3001',
        'http://127.0.0.1:3001',
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
