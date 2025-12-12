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
        Schema::create('bukti_kegiatans', function (Blueprint $table) {
            $table->id('Id_Bukti_Kegiatan');
            $table->unsignedBigInteger('Id_Kegiatan');
            $table->unsignedBigInteger('Id_Profil');
            $table->binary('Bukti_Foto');  // BLOB untuk menyimpan data biner file gambar
            $table->string('mime_type')->nullable();  // Menyimpan tipe MIME (image/jpeg, image/png, dll)
            $table->timestamps();

            // Unique constraint: 1 profil per kegiatan (bukan global unique)
            $table->unique(['Id_Kegiatan', 'Id_Profil']);
            
            // Add foreign key constraints dengan kolom yang BENAR
            $table->foreign('Id_Kegiatan')->references('Id_Kegiatan')->on('kegiatans');
            $table->foreign('Id_Profil')->references('Id_Profil')->on('profil');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('bukti_kegiatans');
    }
    
};
