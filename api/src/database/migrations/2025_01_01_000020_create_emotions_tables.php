<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        // Émotions de base (niveau 1) — Joie, Colère, Peur, Tristesse, Surprise, Dégoût
        Schema::create('emotion_categories', function (Blueprint $table) {
            $table->id('id_emotion_category');
            $table->string('name', 50)->unique();
            $table->string('color_hex', 7); // ex : #B0E0E6
            $table->string('icon', 50)->nullable();
            $table->integer('sort_order')->default(0);
            $table->boolean('is_active')->default(true);
            $table->dateTime('created_at')->useCurrent();
            $table->dateTime('updated_at')->nullable();
        });

        // Émotions de niveau 2 — Fierté, Contentement, etc.
        Schema::create('emotions', function (Blueprint $table) {
            $table->id('id_emotion');
            $table->unsignedBigInteger('id_emotion_category');
            $table->string('name', 50);
            $table->boolean('is_active')->default(true);
            $table->dateTime('created_at')->useCurrent();
            $table->dateTime('updated_at')->nullable();

            $table->foreign('id_emotion_category')
                ->references('id_emotion_category')
                ->on('emotion_categories')
                ->onDelete('cascade');

            $table->unique(['id_emotion_category', 'name']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('emotions');
        Schema::dropIfExists('emotion_categories');
    }
};
