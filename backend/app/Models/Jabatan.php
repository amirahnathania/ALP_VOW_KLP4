<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Carbon\Carbon;

class Jabatan extends Model
{
    protected $primaryKey = 'Id_jabatan';
    protected $table = 'jabatan';
    
    protected $fillable = [
        'Jabatan',
        'Awal_jabatan',
        'Akhir_jabatan',
    ];

    protected $casts = [
        'Id_jabatan' => 'integer',
        'Awal_jabatan' => 'date',
        'Akhir_jabatan' => 'date',
        'created_at' => 'datetime',
        'updated_at' => 'datetime',
    ];

    // Relasi
    public function profil()
    {
        return $this->hasMany(Profil::class, 'Id_jabatan', 'Id_jabatan');
    }

    // Accessors
    public function getStatusAttribute()
    {
        $today = Carbon::today();
        $awal = Carbon::parse($this->Awal_jabatan);
        $akhir = $this->Akhir_jabatan ? Carbon::parse($this->Akhir_jabatan) : null;
        
        if ($today->lessThan($awal)) return 'akan_datang';
        if ($akhir && $today->greaterThan($akhir)) return 'selesai';
        return 'aktif';
    }

    public function getDurasiTahunAttribute()
    {
        $awal = Carbon::parse($this->Awal_jabatan);
        $akhir = $this->Akhir_jabatan ? Carbon::parse($this->Akhir_jabatan) : Carbon::today();
        return $akhir->diffInYears($awal);
    }

    // Helper methods
    public function isAktif()
    {
        return $this->status === 'aktif';
    }

    public function hasProfil()
    {
        return $this->profil()->count() > 0;
    }

    // Scopes
    public function scopeAktif($query)
    {
        $today = Carbon::today()->format('Y-m-d');
        return $query->where('Awal_jabatan', '<=', $today)
                    ->where(function($q) use ($today) {
                        $q->where('Akhir_jabatan', '>=', $today)
                          ->orWhereNull('Akhir_jabatan');
                    });
    }

    // Event handling (backup validation)
    protected static function boot()
    {
        parent::boot();

        static::saving(function ($jabatan) {
            // Backup validation jika ada yang skip Controller
            if ($jabatan->Akhir_jabatan && $jabatan->Awal_jabatan > $jabatan->Akhir_jabatan) {
                throw new \Exception('Tanggal awal tidak boleh setelah tanggal akhir');
            }
        });

        static::deleting(function ($jabatan) {
            if ($jabatan->profil()->count() > 0) {
                throw new \Exception('Tidak dapat menghapus jabatan dengan profil terkait');
            }
        });
    }
}