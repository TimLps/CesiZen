<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Requests\Profile\UpdateProfileRequest;
use App\Http\Resources\UserResource;
use App\Services\UserService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use Illuminate\Validation\Rules\Password;
use Illuminate\Validation\ValidationException;
use OpenApi\Attributes as OA;

class ProfileController extends Controller
{
    public function __construct(
        private readonly UserService $userService,
    ) {}

    #[OA\Get(
        path: '/api/profile',
        summary: 'Récupère le profil utilisateur',
        tags: ['Profil'],
        security: [['bearerAuth' => []]],
        responses: [new OA\Response(response: 200, description: 'Profil OK')]
    )]
    public function show(Request $request): JsonResponse
    {
        return response()->json(
            new UserResource($request->user()->load(['role', 'userState']))
        );
    }

    #[OA\Put(
        path: '/api/profile',
        summary: 'Met à jour le profil utilisateur',
        tags: ['Profil'],
        security: [['bearerAuth' => []]],
        responses: [
            new OA\Response(response: 200, description: 'Profil mis à jour'),
            new OA\Response(response: 422, description: 'Données invalides'),
        ]
    )]
    public function update(UpdateProfileRequest $request): JsonResponse
    {
        $user = $this->userService->updateProfile($request->user(), $request->validated());

        return response()->json(new UserResource($user->load(['role', 'userState'])));
    }

    #[OA\Delete(
        path: '/api/profile',
        summary: 'Supprime son propre compte (soft delete)',
        tags: ['Profil'],
        security: [['bearerAuth' => []]],
        responses: [new OA\Response(response: 200, description: 'Compte supprimé')]
    )]
    public function destroy(Request $request): JsonResponse
    {
        $user = $request->user();
        $user->tokens()->delete();
        $this->userService->deleteUser($user);

        return response()->json(['message' => 'Compte supprimé.']);
    }

    #[OA\Post(
        path: '/api/profile/password',
        summary: 'Change le mot de passe de l\'utilisateur connecté',
        description: 'Exige le mot de passe actuel + nouveau mot de passe confirmé. '
            . 'Révoque tous les tokens existants après le changement, sauf celui '
            . 'utilisé pour la requête (l\'utilisateur reste connecté sur sa session).',
        tags: ['Profil'],
        security: [['bearerAuth' => []]],
        responses: [
            new OA\Response(response: 200, description: 'Mot de passe modifié'),
            new OA\Response(response: 422, description: 'Mot de passe actuel incorrect ou nouveau invalide'),
        ]
    )]
    public function changePassword(Request $request): JsonResponse
    {
        $data = $request->validate([
            'current_password'          => ['required', 'string'],
            'new_password'              => ['required', 'string', Password::defaults(), 'confirmed', 'different:current_password'],
            'new_password_confirmation' => ['required', 'string'],
        ], [
            'new_password.confirmed' => 'La confirmation du nouveau mot de passe ne correspond pas.',
            'new_password.different' => 'Le nouveau mot de passe doit être différent de l\'actuel.',
        ]);

        $user = $request->user();

        if (! Hash::check($data['current_password'], $user->password)) {
            throw ValidationException::withMessages([
                'current_password' => ['Le mot de passe actuel est incorrect.'],
            ]);
        }

        $user->password = Hash::make($data['new_password']);
        $user->save();

        // Sécurité : révoque tous les autres tokens (mais garde celui de la
        // requête courante pour que l'utilisateur reste connecté).
        $currentTokenId = $user->currentAccessToken()?->id;
        if ($currentTokenId) {
            $user->tokens()->where('id', '!=', $currentTokenId)->delete();
        } else {
            $user->tokens()->delete();
        }

        return response()->json(['message' => 'Mot de passe mis à jour.']);
    }
}
