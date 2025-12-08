<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Factories\HasFactory;

class Profil extends Model
{
    use HasFactory;

    protected $primaryKey = 'Id_Profil';
    protected $table = 'profil';
    
    protected $fillable = [
        'Id_User',
        'Id_jabatan',
    ];

    protected $casts = [
        'Id_Profil' => 'integer',
        'Id_User' => 'integer',
        'Id_jabatan' => 'string',
        'created_at' => 'datetime',
        'updated_at' => 'datetime',
    ];

    // Relasi ke User
    public function user()
    {
        return $this->belongsTo(User::class, 'Id_User', 'Id_User');
    }

    // Relasi ke Jabatan
    public function jabatan()
    {
        return $this->belongsTo(Jabatan::class, 'Id_jabatan', 'Id_jabatan');
    }

    protected static function boot()
    {
        parent::boot();

        static::creating(function ($profil) {
            // Validasi tipe data sangat dasar
            if (!is_numeric($profil->Id_User)) {
                throw new \InvalidArgumentException('Id_User harus berupa angka');
            }
            
            if (!is_string($profil->Id_jabatan)) {
                throw new \InvalidArgumentException('Id_jabatan harus berupa string');
            }
        });
    }

    // Scope untuk mendapatkan profil aktif (jabatan masih aktif)
    public function scopeActive($query)
    {
        return $query->whereHas('jabatan', function ($q) {
            $q->where(function ($subQuery) {
                $subQuery->whereNull('Akhir_jabatan')
                        ->orWhere('Akhir_jabatan', '>=', now()->format('Y-m-d'));
            });
        });
    }

    // Cek apakah user sudah memiliki profil
    public static function userHasProfile($userId)
    {
        return self::where('Id_User', $userId)->exists();
    }

    // Cek apakah jabatan sudah diisi (untuk business rule)
    public static function jabatanIsFilled($jabatanId, $excludeProfilId = null)
    {
        $query = self::where('Id_jabatan', $jabatanId);
        
        if ($excludeProfilId) {
            $query->where('Id_Profil', '!=', $excludeProfilId);
        }
        
        return $query->exists();
    }

    // Cek apakah profil ini memiliki jabatan aktif
    public function hasActiveJabatan()
    {
        if (!$this->jabatan) {
            return false;
        }
        
        $today = now()->format('Y-m-d');
        return !$this->jabatan->Akhir_jabatan || $this->jabatan->Akhir_jabatan >= $today;
    }
}