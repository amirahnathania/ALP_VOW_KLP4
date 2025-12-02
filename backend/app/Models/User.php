<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class User extends Model
{
    protected $primaryKey = 'Id_User';
    protected $table = 'users';
    
    protected $fillable = [
        'Nama_Pengguna',
        'Email',
        'Kata_Sandi',
    ];

    protected $hidden = [
        'Kata_Sandi',
    ];

    // Relasi ke Profil
    public function profil()
    {
        return $this->hasOne(Profil::class, 'Id_User');
    }

    /**
     * 1 User memiliki 1 BuktiKegiatan (One-to-One Relationship)
     */
    public function buktiKegiatan()
    {
        return $this->hasOne(BuktiKegiatan::class, 'Id_User');
    }
}