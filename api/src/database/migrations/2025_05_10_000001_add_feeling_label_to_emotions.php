<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

/**
 * Ajoute la forme adjectivale (feeling_label) aux catégories et aux émotions.
 *
 * Permet d'afficher dans l'UI "Vous vous sentez {feeling_label}" :
 *  - catégorie "Colère" → label "en colère"
 *  - émotion  "Hostilité" → label "hostile"
 *
 * Le champ est éditable par l'administrateur via le back-office.
 */
return new class extends Migration
{
    public function up(): void
    {
        Schema::table('emotion_categories', function (Blueprint $table) {
            $table->string('feeling_label', 80)->nullable()->after('name');
        });

        Schema::table('emotions', function (Blueprint $table) {
            $table->string('feeling_label', 80)->nullable()->after('name');
        });
    }

    public function down(): void
    {
        Schema::table('emotions', function (Blueprint $table) {
            $table->dropColumn('feeling_label');
        });
        Schema::table('emotion_categories', function (Blueprint $table) {
            $table->dropColumn('feeling_label');
        });
    }
};
