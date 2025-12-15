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
        Schema::create('kegiatan', function (Blueprint $table) {
            $table->id("id");
            $table->unsignedBigInteger('id_profil')->nullable();
            $table->string('jenis_kegiatan');
            $table->date('tanggal_mulai');
            $table->date('tanggal_selesai');
            $table->time('waktu_mulai');
            $table->time('waktu_selesai');
            $table->string('jenis_pestisida')->nullable();
            $table->integer('target_penanaman');
            $table->text('keterangan')->nullable();
            $table->timestamps();
            $table->foreign('id_profil')->references('id')->on('profil')->onDelete('cascade');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('kegiatan');
    }
};
