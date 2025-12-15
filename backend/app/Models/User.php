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

    protected $primaryKey = 'id';
    protected $table = 'users';

    protected $fillable = [
        'nama_pengguna',
        'email',
        'password',
        'email_verified_at',
        'remember_token',
        'role',
    ];

    protected $hidden = [
        'password',
        'remember_token',
    ];

    protected $casts = [
        'id' => 'integer',
        'email_verified_at' => 'datetime',
        'created_at' => 'datetime',
        'updated_at' => 'datetime',
        'role' => 'string',
    ];

    // ========== MUTATORS ==========

    public function setPasswordAttribute($value)
    {
        if ($value) {
            $this->attributes['password'] = Hash::make($value);
        }
    }

    public function setEmailAttribute($value)
    {
        $this->attributes['email'] = strtolower($value);
    }

    public function setRoleAttribute($value)
    {
        if ($value !== null) {
            $this->attributes['role'] = $value;
            return;
        }

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

    public function getNamaAttribute()
    {
        return $this->nama_pengguna;
    }

    public function getEmailDomainAttribute()
    {
        $domain = substr(strrchr($this->email, "@"), 1);
        return $domain;
    }

    public function getRoleAttribute($value)
    {
        if ($value !== null) {
            return $value;
        }

        $domain = $this->email_domain;

        if ($domain == 'ketua.ac.id') {
            return 'ketua';
        } elseif ($domain == 'gapoktan.ac.id') {
            return 'gapoktan';
        }

        return null;
    }

    // ========== RELATIONS ==========

    public function profil()
    {
        return $this->hasOne(Profil::class, 'id_user', 'id');
    }

    // ========== SCOPES ==========

    public function scopeByEmailDomain($query, $domain)
    {
        return $query->where('email', 'LIKE', '%@' . $domain);
    }

    public function scopeKetua($query)
    {
        return $query->where('role', 'ketua')
            ->orWhere('email', 'LIKE', '%@ketua.ac.id');
    }

    public function scopeGapoktan($query)
    {
        return $query->where('role', 'gapoktan')
            ->orWhere('email', 'LIKE', '%@gapoktan.ac.id');
    }

    public function scopeWithProfil($query)
    {
        return $query->whereHas('profil');
    }

    public function scopeWithoutProfil($query)
    {
        return $query->whereDoesntHave('profil');
    }

    // ========== HELPER METHODS ==========

    public function isKetua()
    {
        return $this->role === 'ketua';
    }

    public function isGapoktan()
    {
        return $this->role === 'gapoktan';
    }

    public function hasProfil()
    {
        return $this->profil !== null;
    }

    public function isEmailVerified()
    {
        return $this->email_verified_at !== null;
    }

    // ========== AUTHENTICATION METHODS ==========

    public function getAuthPassword()
    {
        return $this->password;
    }

    public function getEmailForPasswordReset()
    {
        return $this->email;
    }

    public function getAuthIdentifierName()
    {
        return 'email';
    }
}
