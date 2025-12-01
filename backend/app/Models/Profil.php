<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Profil extends Model
{
    protected $primaryKey = 'Id_Profil';
    protected $table = 'profil';
    
    protected $fillable = [
        'Id_User',
        'Id_jabatan',
    ];

    // Relasi ke User
    public function user()
    {
        return $this->belongsTo(User::class, 'Id_User');
    }

    // Relasi ke Jabatan
    public function jabatan()
    {
        return $this->belongsTo(Jabatan::class, 'Id_jabatan');
    }
}