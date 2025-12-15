<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Factories\HasFactory;

class Profil extends Model
{
    use HasFactory;

    protected $primaryKey = 'id';
    protected $table = 'profil';

    protected $fillable = [
        'id_user',
        'id_jabatan',
    ];

    protected $casts = [
        'id' => 'integer',
        'id_user' => 'integer',
        'id_jabatan' => 'integer',
        'created_at' => 'datetime',
        'updated_at' => 'datetime',
    ];

    // ========== RELATIONS ==========

    public function user()
    {
        return $this->belongsTo(User::class, 'id_user', 'id');
    }

    public function jabatan()
    {
        return $this->belongsTo(Jabatan::class, 'id_jabatan', 'id');
    }

    public function kegiatan()
    {
        return $this->hasMany(Kegiatan::class, 'id_profil', 'id');
    }

    public function buktiKegiatan()
    {
        return $this->hasMany(BuktiKegiatan::class, 'id_profil', 'id');
    }

    // ========== EVENT HANDLING ==========

    protected static function boot()
    {
        parent::boot();

        static::creating(function ($profil) {
            if (!is_numeric($profil->id_user)) {
                throw new \InvalidArgumentException('id_user harus berupa angka');
            }

            if (!is_numeric($profil->id_jabatan)) {
                throw new \InvalidArgumentException('id_jabatan harus berupa angka');
            }
        });
    }

    // ========== SCOPES ==========

    public function scopeActive($query)
    {
        return $query->whereHas('jabatan', function ($q) {
            $q->where(function ($subQuery) {
                $subQuery->whereNull('akhir_jabatan')
                    ->orWhere('akhir_jabatan', '>=', now()->format('Y-m-d'));
            });
        });
    }

    // ========== HELPER METHODS ==========

    public static function userHasProfile($userId)
    {
        return self::where('id_user', $userId)->exists();
    }

    public static function jabatanIsFilled($jabatanId, $excludeProfilId = null)
    {
        $query = self::where('id_jabatan', $jabatanId);

        if ($excludeProfilId) {
            $query->where('id', '!=', $excludeProfilId);
        }

        return $query->exists();
    }

    public function hasActiveJabatan()
    {
        if (!$this->jabatan) {
            return false;
        }

        $today = now()->format('Y-m-d');
        return !$this->jabatan->akhir_jabatan || $this->jabatan->akhir_jabatan >= $today;
    }
}
