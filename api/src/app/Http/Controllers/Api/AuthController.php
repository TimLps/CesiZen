<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Requests\Auth\LoginRequest;
use App\Http\Requests\Auth\RegisterRequest;
use App\Http\Resources\UserResource;
use App\Models\User;
use App\Services\UserService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use OpenApi\Attributes as OA;

class AuthController extends Controller
{
    public function __construct(
        private readonly UserService $userService,
    ) {}

    #[OA\Post(
        path: '/api/auth/register',
        summary: "Inscription d'un nouvel utilisateur",
        tags: ['Authentification'],
        requestBody: new OA\RequestBody(
            required: true,
            content: new OA\JsonContent(
                required: ['first_name', 'last_name', 'email', 'password', 'password_confirmation'],
                properties: [
                    new OA\Property(property: 'first_name', type: 'string', example: 'Jean'),
                    new OA\Property(property: 'last_name', type: 'string', example: 'Dupont'),
                    new OA\Property(property: 'email', type: 'string', example: 'jean@example.com'),
                    new OA\Property(property: 'password', type: 'string', example: 'password123'),
                    new OA\Property(property: 'password_confirmation', type: 'string', example: 'password123'),
                    new OA\Property(property: 'city', type: 'string', nullable: true, example: 'Paris'),
                    new OA\Property(property: 'birth_date', type: 'string', format: 'date', nullable: true),
                ]
            )
        ),
        responses: [
            new OA\Response(response: 201, description: 'Inscription réussie'),
            new OA\Response(response: 422, description: 'Données invalides'),
        ]
    )]
    public function register(RegisterRequest $request): JsonResponse
    {
        $user = $this->userService->registerUser($request->validated());
        $token = $user->createToken('api-token')->plainTextToken;

        return response()->json([
            'message' => 'Inscription réussie',
            'token'   => $token,
            'user'    => new UserResource($user),
        ], 201);
    }

    #[OA\Post(
        path: '/api/auth/login',
        summary: 'Connexion - retourne un token Sanctum',
        tags: ['Authentification'],
        requestBody: new OA\RequestBody(
            required: true,
            content: new OA\JsonContent(
                required: ['email', 'password'],
                properties: [
                    new OA\Property(property: 'email', type: 'string', example: 'admin@cesizen.fr'),
                    new OA\Property(property: 'password', type: 'string', example: 'password'),
                ]
            )
        ),
        responses: [
            new OA\Response(response: 200, description: 'Connexion réussie'),
            new OA\Response(response: 401, description: 'Identifiants incorrects'),
            new OA\Response(response: 403, description: 'Compte inactif'),
        ]
    )]
    public function login(LoginRequest $request): JsonResponse
    {
        $user = User::with(['role', 'userState'])
            ->where('email', $request->email)
            ->first();

        if (! $user || ! Hash::check($request->password, $user->password)) {
            return response()->json(['message' => 'Identifiants incorrects.'], 401);
        }

        if (! $user->isActive()) {
            return response()->json(['message' => 'Votre compte est inactif ou banni.'], 403);
        }

        // Révocation des anciens tokens (session unique)
        $user->tokens()->delete();
        $token = $user->createToken('api-token')->plainTextToken;

        return response()->json([
            'message' => 'Connexion réussie',
            'token'   => $token,
            'user'    => new UserResource($user),
        ]);
    }

    #[OA\Post(
        path: '/api/auth/logout',
        summary: 'Déconnexion',
        tags: ['Authentification'],
        security: [['bearerAuth' => []]],
        responses: [new OA\Response(response: 200, description: 'Déconnexion réussie')]
    )]
    public function logout(Request $request): JsonResponse
    {
        $request->user()->currentAccessToken()->delete();
        return response()->json(['message' => 'Déconnexion réussie.']);
    }

    #[OA\Get(
        path: '/api/auth/me',
        summary: "Profil de l'utilisateur connecté",
        tags: ['Authentification'],
        security: [['bearerAuth' => []]],
        responses: [new OA\Response(response: 200, description: 'Profil utilisateur')]
    )]
    public function me(Request $request): JsonResponse
    {
        return response()->json(
            new UserResource($request->user()->load(['role', 'userState']))
        );
    }
}
