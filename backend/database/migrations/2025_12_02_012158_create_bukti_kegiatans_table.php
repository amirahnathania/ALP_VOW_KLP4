<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;
use Illuminate\Support\Facades\DB;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        Schema::create('bukti_kegiatan', function (Blueprint $table) {
            $table->id('id');
            $table->unsignedBigInteger('id_kegiatan');
            $table->unsignedBigInteger('id_profil');
            $table->string('nama_foto');
            $table->string('tipe_foto');
            $table->timestamps();
            $table->unique(['id_kegiatan', 'id_profil']);
            $table->foreign('id_kegiatan')->references('id')->on('kegiatan');
            $table->foreign('id_profil')->references('id')->on('profil');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('bukti_kegiatan');
    }

};
