<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

/**
 * Crée la table info_page_categories (thèmes éditoriaux) et lie chaque article
 * à une catégorie + à son auteur (created_by) et dernier modificateur (updated_by).
 *
 *  - Côté mobile : la catégorie est visible (navigation par thème), mais
 *    created_by / updated_by ne sont jamais exposés.
 *  - Côté back-office : created_by / updated_by sont visibles pour permettre
 *    à l'administrateur d'identifier le modérateur responsable d'un contenu.
 */
return new class extends Migration
{
    public function up(): void
    {
        Schema::create('info_page_categories', function (Blueprint $table) {
            $table->id('id_info_page_category');
            $table->string('name', 100)->unique();
            $table->string('slug', 100)->unique();
            $table->string('icon', 50)->nullable();
            $table->string('color_hex', 7)->nullable();
            $table->integer('sort_order')->default(0);
            $table->boolean('is_active')->default(true);
            $table->dateTime('created_at')->useCurrent();
            $table->dateTime('updated_at')->nullable();
        });

        Schema::table('info_pages', function (Blueprint $table) {
            $table->unsignedBigInteger('id_info_page_category')->nullable()->after('content');
            $table->unsignedBigInteger('created_by')->nullable()->after('id_info_page_category');
            $table->unsignedBigInteger('updated_by')->nullable()->after('created_by');

            $table->foreign('id_info_page_category')
                ->references('id_info_page_category')
                ->on('info_page_categories')
                ->onDelete('set null');

            $table->foreign('created_by')
                ->references('id_user')
                ->on('users')
                ->onDelete('set null');

            $table->foreign('updated_by')
                ->references('id_user')
                ->on('users')
                ->onDelete('set null');

            $table->index('id_info_page_category');
        });
    }

    public function down(): void
    {
        Schema::table('info_pages', function (Blueprint $table) {
            $table->dropForeign(['id_info_page_category']);
            $table->dropForeign(['created_by']);
            $table->dropForeign(['updated_by']);
            $table->dropIndex(['id_info_page_category']);
            $table->dropColumn(['id_info_page_category', 'created_by', 'updated_by']);
        });

        Schema::dropIfExists('info_page_categories');
    }
};
