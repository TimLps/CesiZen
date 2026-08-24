<?php

use App\Http\Controllers\Api\AdminDashboardController;
use App\Http\Controllers\Api\AdminEmotionController;
use App\Http\Controllers\Api\AdminInfoPageCategoryController;
use App\Http\Controllers\Api\AdminInfoPageController;
use App\Http\Controllers\Api\AdminUserController;
use App\Http\Controllers\Api\AuthController;
use App\Http\Controllers\Api\EmotionCategoryController;
use App\Http\Controllers\Api\EmotionJournalController;
use App\Http\Controllers\Api\InfoPageCategoryController;
use App\Http\Controllers\Api\InfoPageController;
use App\Http\Controllers\Api\PasswordController;
use App\Http\Controllers\Api\ProfileController;
use Illuminate\Support\Facades\Route;

// ── Healthcheck ───────────────────────────────────────────────────────────────
Route::get('/health', fn () => response()->json([
    'status'  => 'ok',
    'service' => 'CESIZen API',
    'time'    => now()->toIso8601String(),
]));

// ── Authentification publique ─────────────────────────────────────────────────
Route::prefix('auth')->group(function () {
    Route::post('/register',        [AuthController::class, 'register']);
    Route::post('/login',           [AuthController::class, 'login']);
    Route::post('/forgot-password', [PasswordController::class, 'forgotPassword']);
    Route::post('/reset-password',  [PasswordController::class, 'resetPassword']);
});

// ── Modules publics (lecture seule) ───────────────────────────────────────────
// Module Informations - Front-Office accessible aux visiteurs anonymes
Route::get('/info-page-categories',  [InfoPageCategoryController::class, 'index']);
Route::get('/info-pages',            [InfoPageController::class, 'index']);
Route::get('/info-pages/{idOrSlug}', [InfoPageController::class, 'show']);

// Référentiel d'émotions accessible aux visiteurs anonymes (cf. sujet CESIZen
// §D.3 : le visiteur peut renseigner son émotion actuelle, donc voir le référentiel).
// La saisie elle-même reste protégée — seule la lecture du catalogue est publique.
Route::get('/emotion-categories', [EmotionCategoryController::class, 'index']);

// ══════════════════════════════════════════════════════════════════════════════
// ROUTES PROTÉGÉES (Sanctum)
// ══════════════════════════════════════════════════════════════════════════════
Route::middleware('auth:sanctum')->group(function () {

    // ── Auth & session ────────────────────────────────────────────────────────
    Route::prefix('auth')->group(function () {
        Route::post('/logout', [AuthController::class, 'logout']);
        Route::get('/me',      [AuthController::class, 'me']);
    });

    // ── Profil personnel ──────────────────────────────────────────────────────
    Route::prefix('profile')->group(function () {
        Route::get('/',         [ProfileController::class, 'show']);
        Route::put('/',         [ProfileController::class, 'update']);
        Route::delete('/',      [ProfileController::class, 'destroy']);
        Route::post('/password', [ProfileController::class, 'changePassword']);
    });

    // ── Journal d'émotions (utilisateur connecté) ─────────────────────────────
    Route::prefix('journal')->group(function () {
        Route::get('/report',  [EmotionJournalController::class, 'report']); // avant /{id}
        Route::get('/top-24h', [EmotionJournalController::class, 'top24h']);
        Route::get('/',        [EmotionJournalController::class, 'index']);
        Route::post('/',      [EmotionJournalController::class, 'store']);
        Route::get('/{id}',   [EmotionJournalController::class, 'show'])->whereNumber('id');
        Route::put('/{id}',   [EmotionJournalController::class, 'update'])->whereNumber('id');
        Route::delete('/{id}',[EmotionJournalController::class, 'destroy'])->whereNumber('id');
    });

    // ══════════════════════════════════════════════════════════════════════════
    // BACK-OFFICE - réservé aux administrateurs
    // ══════════════════════════════════════════════════════════════════════════
    Route::middleware('role:admin')->prefix('admin')->group(function () {

        Route::get('/dashboard', [AdminDashboardController::class, 'index']);

        // Gestion utilisateurs
        Route::prefix('users')->group(function () {
            Route::get('/',                [AdminUserController::class, 'index']);
            Route::post('/',               [AdminUserController::class, 'store']);
            Route::get('/{id}',            [AdminUserController::class, 'show']);
            Route::put('/{id}',            [AdminUserController::class, 'update']);
            Route::patch('/{id}/deactivate', [AdminUserController::class, 'deactivate']);
            Route::delete('/{id}',         [AdminUserController::class, 'destroy']);
        });

        // Gestion des thèmes (catégories) d'articles
        Route::prefix('info-page-categories')->group(function () {
            Route::get('/',        [AdminInfoPageCategoryController::class, 'index']);
            Route::post('/',       [AdminInfoPageCategoryController::class, 'store']);
            Route::put('/{id}',    [AdminInfoPageCategoryController::class, 'update']);
            Route::delete('/{id}', [AdminInfoPageCategoryController::class, 'destroy']);
        });

        // Gestion des pages d'information
        Route::prefix('info-pages')->group(function () {
            Route::get('/',     [AdminInfoPageController::class, 'index']);
            Route::post('/',    [AdminInfoPageController::class, 'store']);
            Route::get('/{id}', [AdminInfoPageController::class, 'show']);
            Route::put('/{id}', [AdminInfoPageController::class, 'update']);
            Route::delete('/{id}', [AdminInfoPageController::class, 'destroy']);
        });

        // Gestion des émotions et catégories
        Route::prefix('emotion-categories')->group(function () {
            Route::get('/',    [AdminEmotionController::class, 'listCategories']);
            Route::post('/',   [AdminEmotionController::class, 'storeCategory']);
            Route::put('/{id}',    [AdminEmotionController::class, 'updateCategory']);
            Route::delete('/{id}', [AdminEmotionController::class, 'destroyCategory']);
        });

        Route::prefix('emotions')->group(function () {
            Route::post('/',       [AdminEmotionController::class, 'storeEmotion']);
            Route::put('/{id}',    [AdminEmotionController::class, 'updateEmotion']);
            Route::delete('/{id}', [AdminEmotionController::class, 'destroyEmotion']);
        });

    });
});
