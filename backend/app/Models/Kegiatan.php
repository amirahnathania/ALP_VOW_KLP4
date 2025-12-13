<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Kegiatan extends Model
{
    protected $primaryKey = 'Id_Kegiatan';
    protected $table = 'kegiatans';
    
    protected $fillable = [
        'Jenis_Kegiatan',
        'Id_Profil',
        'Tanggal_Mulai',
        'Tanggal_Selesai',
        'Waktu_Mulai',
        'Waktu_Selesai',
        'Jenis_Pestisida',
        'Target_Penanaman',
        'Keterangan',
    ];

    // Validasi sebelum menyimpan
    protected static function booted()
    {
        static::creating(function ($model) {
            if ($model->Waktu_Mulai === $model->Waktu_Selesai) {
                throw new \Exception('waktu mulai dan waktu selesai tidak boleh sama');
            }
        });

        static::updating(function ($model) {
            if ($model->Waktu_Mulai === $model->Waktu_Selesai) {
                throw new \Exception('waktu mulai dan waktu selesai tidak boleh sama');
            }
        });
    }
    
public function profil()
    {
        return $this->belongsTo(Profil::class,  'Id_Profil');
    }

    /**
     * Relasi dengan BuktiKegiatan
     */
    public function buktiKegiatans()
    {
        return $this->hasMany(BuktiKegiatan::class, 'Id_Kegiatan');
    }
}
