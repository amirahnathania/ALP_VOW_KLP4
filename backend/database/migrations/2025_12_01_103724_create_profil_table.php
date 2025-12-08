<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        Schema::create('profil', function (Blueprint $table) {
            $table->id('Id_Profil');

            $table->unsignedBigInteger('Id_User');
            $table->unsignedBigInteger('Id_jabatan');

            $table->foreign('Id_User')->references('Id_User')->on('users')->onDelete('cascade');
            $table->foreign('Id_jabatan')->references('Id_jabatan')->on('jabatan')->onDelete('cascade');
            
            $table->timestamps();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('profil');
    }
};
