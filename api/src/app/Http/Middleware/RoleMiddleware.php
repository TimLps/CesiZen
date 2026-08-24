<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\Response;

class RoleMiddleware
{
    /**
     * Usage: ->middleware('role:admin') ou ->middleware('role:admin,user')
     */
    public function handle(Request $request, Closure $next, string ...$roles): Response
    {
        $user = $request->user();

        if (! $user) {
            return response()->json(['message' => 'Non authentifié.'], 401);
        }

        if (! $user->isActive()) {
            return response()->json(['message' => 'Compte inactif.'], 403);
        }

        $userRoleName = $user->role?->name;

        if (! in_array($userRoleName, $roles, true)) {
            return response()->json([
                'message' => 'Accès refusé : rôle insuffisant.',
            ], 403);
        }

        return $next($request);
    }
}
