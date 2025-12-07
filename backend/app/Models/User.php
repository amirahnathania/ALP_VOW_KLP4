<?php

namespace App\Models;

use Illuminate\Foundation\Auth\User as Authenticatable;
use Illuminate\Notifications\Notifiable;
use Laravel\Sanctum\HasApiTokens;

class User extends Authenticatable
{
    use HasApiTokens, Notifiable;
    
    protected $primaryKey = 'Id_User';
    protected $table = 'users';
    
    /**
     * Kolom yang bisa diisi mass assignment
     */
    protected $fillable = [
        'Nama_Pengguna',
        'Email',
        'Kata_Sandi',
        'email_verified_at',
        'remember_token',
        'role',
    ];

    // Kolom yang disembunyikan dari response
    protected $hidden = [
        'Kata_Sandi',
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

    // ========== AUTHENTICATION METHODS ==========
    
    // Untuk mendapatkan kolom password
    public function getAuthPassword()
    {
        return $this->Kata_Sandi;
    }
    
    // Untuk mendapatkan kolom email untuk password reset
    public function getEmailForPasswordReset()
    {
        return $this->Email;
    }
    
    // Nama identifier untuk authentication
    public function getAuthIdentifierName()
    {
        return 'Email';
    }
    
    // Relasi one-to-one dengan Profil
    public function profil()
    {
        return $this->hasOne(Profil::class, 'Id_User', 'Id_User');
    }

    public function buktiKegiatan()
    {
        return $this->hasMany(BuktiKegiatan::class, 'Id_User', 'Id_User');
    }
  
    // Accessor untuk nama (alias Nama_Pengguna)
    public function getNamaAttribute()
    {
        return $this->Nama_Pengguna;
    }
    
    // Accessor untuk mengambil domain dari email
    public function getEmailDomainAttribute()
    {
        $domain = substr(strrchr($this->Email, "@"), 1);
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
    // ========== END ACCESSORS ==========

    // ========== MUTATORS (SETTERS) ==========
    
    // Auto-hash password saat di-set
    public function setKataSandiAttribute($value)
    {
        $this->attributes['Kata_Sandi'] = bcrypt($value);
    }
    
    // Format email ke lowercase saat di-set
    public function setEmailAttribute($value)
    {
        $this->attributes['Email'] = strtolower($value);
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
        $email = $this->attributes['Email'] ?? null;
        if ($email) {
            $domain = substr(strrchr($email, "@"), 1);
            
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
    
    // Scope untuk user dengan domain email tertentu
    public function scopeByEmailDomain($query, $domain)
    {
        return $query->where('Email', 'LIKE', '%@' . $domain);
    }
    
    // Scope untuk user ketua
    public function scopeKetua($query)
    {
        return $query->where('role', 'ketua')
                    ->orWhere('Email', 'LIKE', '%@ketua.ac.id');
    }
    
    // Scope untuk user gapoktan
    public function scopeGapoktan($query)
    {
        return $query->where('role', 'gapoktan')
                    ->orWhere('Email', 'LIKE', '%@gapoktan.ac.id');
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

    //Boot method untuk event handling
    protected static function boot()
    {
        parent::boot();
        static::creating(function ($user) {
            $allowedDomains = ['ketua.ac.id', 'gapoktan.ac.id'];
            $domain = substr(strrchr($user->Email, "@"), 1);
            
            // Validasi domain email
            if (!in_array($domain, $allowedDomains)) {
                throw new \Exception('Email harus menggunakan domain @ketua.ac.id atau @gapoktan.ac.id');
            }
            
            // Auto-set role jika tidak diset
            if (!isset($user->attributes['role']) || $user->attributes['role'] === null) {
                if ($domain == 'ketua.ac.id') {
                    $user->attributes['role'] = 'ketua';
                } elseif ($domain == 'gapoktan.ac.id') {
                    $user->attributes['role'] = 'gapoktan';
                }
            }
        });

        static::updating(function ($user) {
            if ($user->isDirty('Email')) {
                $allowedDomains = ['ketua.ac.id', 'gapoktan.ac.id'];
                $domain = substr(strrchr($user->Email, "@"), 1);
                
                // Validasi domain email baru
                if (!in_array($domain, $allowedDomains)) {
                    throw new \Exception('Email harus menggunakan domain @ketua.ac.id atau @gapoktan.ac.id');
                }
                
                // Update role berdasarkan domain baru
                if ($domain == 'ketua.ac.id') {
                    $user->attributes['role'] = 'ketua';
                } elseif ($domain == 'gapoktan.ac.id') {
                    $user->attributes['role'] = 'gapoktan';
                }
            }
        });
    }
}