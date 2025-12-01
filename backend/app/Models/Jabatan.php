<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Jabatan extends Model
{
    protected $primaryKey = 'Id_jabatan';
    protected $table = 'jabatan';
    
    protected $fillable = [
        'Jabatan',
        'Awal_jabatan',
        'Akhir_jabatan',
    ];

    // Relasi ke Profil
    public function profil()
    {
        return $this->hasMany(Profil::class, 'Id_jabatan');
    }
}