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
            $table->id();
            $table->unsignedBigInteger('Id_Kegiatan');
            $table->unsignedBigInteger('Id_User')->unique();  // Unique untuk relasi 1-to-1
            $table->longBlob('Bukti_Foto');  // BLOB untuk menyimpan data biner file gambar
            $table->string('mime_type')->nullable();  // Menyimpan tipe MIME (image/jpeg, image/png, dll)
            $table->timestamps();

            // Add foreign key constraints dengan kolom yang BENAR
            $table->foreign('Id_Kegiatan')->references('Id_Kegiatan')->on('kegiatans');
            $table->foreign('Id_User')->references('Id_User')->on('users');
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
