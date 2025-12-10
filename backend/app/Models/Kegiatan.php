<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Kegiatan extends Model
{
    protected $primaryKey = 'Id_Kegiatan';
    protected $table = 'kegiatans';
    
    protected $fillable = [
        'Jenis_Kegiatan',
        'Id_Profil',
        'Tanggal',
        'Waktu',
        'Jenis_Pestisida',
        'Target_Penanaman',
        'Keterangan',
    ];
    
public function profil()
    {
        return $this->belongsTo(Profil::class,  'Id_Profil');
    }
}
