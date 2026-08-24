<?php

namespace App;

use OpenApi\Attributes as OA;

#[OA\Info(
    version: '1.0.0',
    title: 'CESIZen API',
    description: 'API REST pour l\'application CESIZen — Santé mentale, gestion du stress, journal d\'émotions et exercices de cohérence cardiaque.',
    contact: new OA\Contact(name: 'CESIZen Team', email: 'contact@cesizen.fr'),
)]
#[OA\Server(url: 'http://localhost:8001', description: 'Environnement local')]
#[OA\SecurityScheme(
    securityScheme: 'bearerAuth',
    type: 'http',
    scheme: 'bearer',
    bearerFormat: 'Sanctum',
)]
class OpenApi
{
    // Cette classe sert uniquement à porter les attributs racine OpenAPI.
}
