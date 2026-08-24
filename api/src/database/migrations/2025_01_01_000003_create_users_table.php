<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('users', function (Blueprint $table) {
            $table->id('id_user');
            $table->string('first_name', 50);
            $table->string('last_name', 50);
            $table->string('email', 255)->unique();
            $table->string('password', 255);
            $table->string('city', 100)->nullable();
            $table->date('birth_date')->nullable();

            $table->unsignedBigInteger('id_role');
            $table->unsignedBigInteger('id_user_state');

            $table->dateTime('created_at')->useCurrent();
            $table->dateTime('updated_at')->nullable();
            $table->softDeletes();

            $table->foreign('id_role')
                ->references('id_role')
                ->on('roles')
                ->onDelete('restrict');

            $table->foreign('id_user_state')
                ->references('id_user_state')
                ->on('user_states')
                ->onDelete('restrict');
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('users');
    }
};
