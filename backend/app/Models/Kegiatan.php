<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Kegiatan extends Model
{
    protected $primaryKey = 'Id_Kegiatan';
    protected $table = 'kegiatans';
    
    protected $fillable = [
        'Nama_Kegiatan',
        'Deskripsi',
        'Tanggal',
        'Waktu',
        'Target_Penanaman',
    ];
}
