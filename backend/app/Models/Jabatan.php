<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Carbon\Carbon;

class Jabatan extends Model
{
    protected $primaryKey = 'id';
    protected $table = 'jabatan';

    protected $fillable = [
        'jabatan',
        'awal_jabatan',
        'akhir_jabatan',
    ];

    protected $casts = [
        'id' => 'integer',
        'awal_jabatan' => 'date',
        'akhir_jabatan' => 'date',
        'created_at' => 'datetime',
        'updated_at' => 'datetime',
    ];

    // ========== RELATIONS ==========

    public function profil()
    {
        return $this->hasMany(Profil::class, 'id_jabatan', 'id');
    }

    // ========== ACCESSORS ==========

    public function getStatusAttribute()
    {
        $today = Carbon::today();
        $awal = Carbon::parse($this->awal_jabatan);
        $akhir = $this->akhir_jabatan ? Carbon::parse($this->akhir_jabatan) : null;

        if ($today->lessThan($awal)) return 'akan_datang';
        if ($akhir && $today->greaterThan($akhir)) return 'selesai';
        return 'aktif';
    }

    public function getDurasiTahunAttribute()
    {
        $awal = Carbon::parse($this->awal_jabatan);
        $akhir = $this->akhir_jabatan ? Carbon::parse($this->akhir_jabatan) : Carbon::today();
        return $akhir->diffInYears($awal);
    }

    // ========== HELPER METHODS ==========

    public function isAktif()
    {
        return $this->status === 'aktif';
    }

    public function hasProfil()
    {
        return $this->profil()->count() > 0;
    }

    // ========== SCOPES ==========

    public function scopeAktif($query)
    {
        $today = Carbon::today()->format('Y-m-d');
        return $query->where('awal_jabatan', '<=', $today)
            ->where(function ($q) use ($today) {
                $q->where('akhir_jabatan', '>=', $today)
                    ->orWhereNull('akhir_jabatan');
            });
    }

    // ========== EVENT HANDLING ==========

    protected static function boot()
    {
        parent::boot();

        static::saving(function ($jabatan) {
            if ($jabatan->akhir_jabatan && $jabatan->awal_jabatan > $jabatan->akhir_jabatan) {
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
