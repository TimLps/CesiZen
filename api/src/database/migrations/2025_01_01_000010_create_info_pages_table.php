<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('info_pages', function (Blueprint $table) {
            $table->id('id_info_page');
            $table->string('slug', 100)->unique();
            $table->string('title', 200);
            $table->string('menu_label', 100);
            $table->longText('content'); // HTML/Markdown
            $table->integer('sort_order')->default(0);
            $table->boolean('is_published')->default(true);
            $table->dateTime('created_at')->useCurrent();
            $table->dateTime('updated_at')->nullable();
            $table->softDeletes();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('info_pages');
    }
};
