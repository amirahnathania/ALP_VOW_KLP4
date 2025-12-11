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
        Schema::create('kegiatans', function (Blueprint $table) {
            $table->id("Id_Kegiatan");
            $table->string('Jenis_Kegiatan');
            $table->unsignedBigInteger('Id_Profil')->nullable();
            $table->date('Tanggal_Mulai');
            $table->date('Tanggal_Selesai');
            $table->time('Waktu_Mulai');
            $table->time('Waktu_Selesai');
            $table->string('Jenis_Pestisida')->nullable();
            $table->integer('Target_Penanaman')->nullable();  // Ubah menjadi nullable
            $table->text('Keterangan')->nullable();
            $table->timestamps();
            
            // Foreign Key
            $table->foreign('Id_profil')->references('Id_Profil')->on('profil')->onDelete('cascade');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('kegiatans');
    }
};
