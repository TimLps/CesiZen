<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('emotion_journal_entries', function (Blueprint $table) {
            $table->id('id_journal_entry');
            $table->unsignedBigInteger('id_user');
            $table->unsignedBigInteger('id_emotion');
            $table->date('entry_date');
            $table->text('note')->nullable();
            $table->dateTime('created_at')->useCurrent();
            $table->dateTime('updated_at')->nullable();

            $table->foreign('id_user')
                ->references('id_user')
                ->on('users')
                ->onDelete('cascade');

            $table->foreign('id_emotion')
                ->references('id_emotion')
                ->on('emotions')
                ->onDelete('restrict');

            $table->index(['id_user', 'entry_date']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('emotion_journal_entries');
    }
};
