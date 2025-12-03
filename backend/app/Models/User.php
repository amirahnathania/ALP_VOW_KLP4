<?php

namespace App\Models;

//use Illuminate\Database\Eloquent\Model;
use Illuminate\Foundation\Auth\User as Authenticatable; // ← GANTI INI
use Illuminate\Notifications\Notifiable;
use Laravel\Sanctum\HasApiTokens; // ← TAMBAH INI

class User extends Authenticatable // ← GANTI Model jadi Authenticatable
{
    use HasApiTokens, Notifiable; // ← TAMBAH INI
    
    protected $primaryKey = 'Id_User';
    protected $table = 'users';
    
    protected $fillable = [
        'Nama_Pengguna',
        'Email',
        'Kata_Sandi',
        'role', // ← TAMBAH INI jika ada kolom role
    ];

    protected $hidden = [
        'Kata_Sandi',
        'remember_token',
    ];

    // ========== TAMBAHAN UNTUK AUTHENTICATION ==========
    
    // Untuk mendapatkan kolom password
    public function getAuthPassword()
    {
        return $this->Kata_Sandi;
    }
    
    // Untuk mendapatkan kolom email
    public function getEmailForPasswordReset()
    {
        return $this->Email;
    }
    
    // Casting
    protected $casts = [
        'email_verified_at' => 'datetime',
    ];
    
    // Mapping nama kolom untuk authentication
    public function getEmailAttribute()
    {
        return $this->Email;
    }
    
    public function getNameAttribute()
    {
        return $this->Nama_Pengguna;
    }
    
    public function getPasswordAttribute()
    {
        return $this->Kata_Sandi;
    }
    // ========== END AUTHENTICATION ==========

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