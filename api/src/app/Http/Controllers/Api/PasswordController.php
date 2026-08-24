<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Requests\Auth\ForgotPasswordRequest;
use App\Http\Requests\Auth\ResetPasswordRequest;
use App\Models\User;
use Illuminate\Http\JsonResponse;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Str;
use OpenApi\Attributes as OA;

class PasswordController extends Controller
{
    #[OA\Post(
        path: '/api/auth/forgot-password',
        summary: 'Demande la réinitialisation du mot de passe par email',
        tags: ['Authentification'],
        responses: [new OA\Response(response: 200, description: 'Email envoyé (ou compte inexistant pour ne pas révéler d\'info)')]
    )]
    public function forgotPassword(ForgotPasswordRequest $request): JsonResponse
    {
        $email = $request->validated('email');

        $token = Str::random(64);

        DB::table('password_reset_tokens')->updateOrInsert(
            ['email' => $email],
            [
                'email'      => $email,
                'token'      => Hash::make($token),
                'created_at' => now(),
            ]
        );

        // En prod, on enverrait un email contenant le token.
        // Pour le projet d'évaluation on logge le token dans storage/logs/laravel.log
        Log::info("[PasswordReset] Token pour {$email} : {$token}");

        return response()->json([
            'message' => 'Si cet email correspond à un compte, un lien vous sera envoyé.',
        ]);
    }

    #[OA\Post(
        path: '/api/auth/reset-password',
        summary: 'Réinitialise le mot de passe à partir d\'un token',
        tags: ['Authentification'],
        responses: [
            new OA\Response(response: 200, description: 'Mot de passe réinitialisé'),
            new OA\Response(response: 400, description: 'Token invalide ou expiré'),
        ]
    )]
    public function resetPassword(ResetPasswordRequest $request): JsonResponse
    {
        $data = $request->validated();

        $row = DB::table('password_reset_tokens')->where('email', $data['email'])->first();

        if (! $row) {
            return response()->json(['message' => 'Token invalide.'], 400);
        }

        if (! Hash::check($data['token'], $row->token)) {
            return response()->json(['message' => 'Token invalide.'], 400);
        }

        // Token valable 60 minutes
        if (now()->diffInMinutes($row->created_at) > 60) {
            return response()->json(['message' => 'Token expiré.'], 400);
        }

        $user = User::where('email', $data['email'])->first();
        if (! $user) {
            return response()->json(['message' => 'Utilisateur introuvable.'], 400);
        }

        $user->password = $data['password']; // hashé via cast 'hashed'
        $user->save();
        $user->tokens()->delete(); // invalide toutes les sessions

        DB::table('password_reset_tokens')->where('email', $data['email'])->delete();

        return response()->json(['message' => 'Mot de passe réinitialisé avec succès.']);
    }
}
