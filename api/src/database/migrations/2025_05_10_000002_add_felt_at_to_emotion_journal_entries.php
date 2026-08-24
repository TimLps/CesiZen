<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

/**
 * Distingue le moment de la saisie (created_at) du moment réellement ressenti
 * (felt_at), pour permettre à l'utilisateur d'enregistrer une émotion qu'il
 * a ressentie 5/10/15/30/60 minutes avant.
 *
 * Règles :
 *  - created_at = horodatage de la requête → utilisé pour le cooldown 5 min serveur
 *  - felt_at    = horodatage du ressenti  → utilisé par les rapports et l'accueil
 *  - entry_date = date du felt_at (héritée, pour les rapports par jour)
 */
return new class extends Migration
{
    public function up(): void
    {
        Schema::table('emotion_journal_entries', function (Blueprint $table) {
            $table->dateTime('felt_at')->nullable()->after('entry_date');
            $table->index(['id_user', 'felt_at']);
        });

        // Backfill : on aligne felt_at sur entry_date pour les anciennes entrées
        \DB::statement('UPDATE emotion_journal_entries SET felt_at = entry_date WHERE felt_at IS NULL');
    }

    public function down(): void
    {
        Schema::table('emotion_journal_entries', function (Blueprint $table) {
            $table->dropIndex(['id_user', 'felt_at']);
            $table->dropColumn('felt_at');
        });
    }
};
