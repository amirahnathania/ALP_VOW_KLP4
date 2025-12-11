<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Foundation\Auth\User as Authenticatable;
use Illuminate\Notifications\Notifiable;
use Laravel\Sanctum\HasApiTokens;
use Illuminate\Support\Facades\Hash;

class User extends Authenticatable
{
    use HasApiTokens, HasFactory, Notifiable;

    protected $primaryKey = 'Id_User';
    protected $table = 'users';

    /**
     * Kolom yang bisa diisi mass assignment
     */
    protected $fillable = [
        'Nama_Pengguna',
        'email',
        'password',
        'email_verified_at',
        'remember_token',
        'role',
    ];

    // Kolom yang disembunyikan dari response
    protected $hidden = [
        'password',
        'remember_token',
    ];

    // Casting tipe data
    protected $casts = [
        'Id_User' => 'integer',
        'email_verified_at' => 'datetime',
        'created_at' => 'datetime',
        'updated_at' => 'datetime',
        'role' => 'string',
    ];

    // ========== MUTATORS ==========

    // Mutator untuk password hashing
    public function setPasswordAttribute($value)
    {
        if ($value) {
            // Only hash if it's not already a bcrypt hash
            // Bcrypt hashes start with $2y$ and are 60 characters long
            if (preg_match('/^\$2[ayb]\$.{56}$/', $value)) {
                $this->attributes['password'] = $value;
            } else {
                $this->attributes['password'] = Hash::make($value);
            }
        }
    }

    // Format email ke lowercase saat di-set
    public function setEmailAttribute($value)
    {
        $this->attributes['email'] = strtolower($value);
    }

    // Mutator untuk role: auto-set dari domain email jika tidak diset
    public function setRoleAttribute($value)
    {
        // Jika value diberikan, simpan itu
        if ($value !== null) {
            $this->attributes['role'] = $value;
            return;
        }

        // Jika null, coba hitung dari domain email
        $email = $this->attributes['email'] ?? $this->email;
        if ($email) {
            $domain = substr(strrchr(strtolower($email), "@"), 1);

            if ($domain == 'ketua.ac.id') {
                $this->attributes['role'] = 'ketua';
            } elseif ($domain == 'gapoktan.ac.id') {
                $this->attributes['role'] = 'gapoktan';
            } else {
                $this->attributes['role'] = null;
            }
        } else {
            $this->attributes['role'] = null;
        }
    }

    // ========== ACCESSORS ==========

    // Accessor untuk nama (alias Nama_Pengguna)
    public function getNamaAttribute()
    {
        return $this->Nama_Pengguna;
    }

    // Accessor untuk mengambil domain dari email
    public function getEmailDomainAttribute()
    {
        $domain = substr(strrchr($this->email, "@"), 1);
        return $domain;
    }

    // Accessor untuk role: jika null, hitung dari domain email
    public function getRoleAttribute($value)
    {
        // Jika role sudah ada di database, pakai itu
        if ($value !== null) {
            return $value;
        }

        // Jika null, hitung dari domain email
        $domain = $this->email_domain;

        if ($domain == 'ketua.ac.id') {
            return 'ketua';
        } elseif ($domain == 'gapoktan.ac.id') {
            return 'gapoktan';
        }

        return null;
    }

    // ========== RELATIONS ==========

    // Relasi one-to-one dengan Profil
    public function profil()
    {
        return $this->hasOne(Profil::class, 'Id_User', 'Id_User');
    }

    public function buktiKegiatan()
    {
        return $this->hasMany(BuktiKegiatan::class, 'Id_User', 'Id_User');
    }

    // ========== SCOPES ==========

    // Scope untuk user dengan domain email tertentu
    public function scopeByEmailDomain($query, $domain)
    {
        return $query->where('email', 'LIKE', '%@' . $domain);
    }

    // Scope untuk user ketua
    public function scopeKetua($query)
    {
        return $query->where('role', 'ketua')
                    ->orWhere('email', 'LIKE', '%@ketua.ac.id');
    }

    // Scope untuk user gapoktan
    public function scopeGapoktan($query)
    {
        return $query->where('role', 'gapoktan')
                    ->orWhere('email', 'LIKE', '%@gapoktan.ac.id');
    }

    // Scope untuk user dengan profil
    public function scopeWithProfil($query)
    {
        return $query->whereHas('profil');
    }

    // Scope untuk user tanpa profil
    public function scopeWithoutProfil($query)
    {
        return $query->whereDoesntHave('profil');
    }

    // ========== HELPER METHODS ==========

    // Cek apakah user adalah ketua
    public function isKetua()
    {
        return $this->role === 'ketua';
    }

    // Cek apakah user adalah gapoktan
    public function isGapoktan()
    {
        return $this->role === 'gapoktan';
    }

    // Cek apakah user sudah memiliki profil
    public function hasProfil()
    {
        return $this->profil !== null;
    }

    // Cek apakah email sudah diverifikasi
    public function isEmailVerified()
    {
        return $this->email_verified_at !== null;
    }

    // ========== AUTHENTICATION METHODS (optional) ==========

    // Untuk mendapatkan kolom password
    public function getAuthPassword()
    {
        return $this->password;
    }

    // Untuk mendapatkan kolom email untuk password reset
    public function getEmailForPasswordReset()
    {
        return $this->email;
    }

    // Nama identifier untuk authentication
    public function getAuthIdentifierName()
    {
        return 'email';
    }
}
