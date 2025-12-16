<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Kegiatan extends Model
{
    protected $primaryKey = 'id';
    protected $table = 'kegiatan';

    protected $fillable = [
        'jenis_kegiatan',
        'id_profil',
        'tanggal_mulai',
        'tanggal_selesai',
        'waktu_mulai',
        'waktu_selesai',
        'jenis_pestisida',
        'target_penanaman',
        'keterangan',
    ];

    protected $casts = [
        'id' => 'integer',
        'id_profil' => 'integer',
        'tanggal_mulai' => 'date',
        'tanggal_selesai' => 'date',
        'target_penanaman' => 'integer',
        'created_at' => 'datetime',
        'updated_at' => 'datetime',
    ];

    // ========== EVENT HANDLING ==========

    protected static function booted()
    {
        static::creating(function ($model) {
            if ($model->waktu_mulai === $model->waktu_selesai) {
                throw new \Exception('waktu mulai dan waktu selesai tidak boleh sama');
            }
        });

        static::updating(function ($model) {
            if ($model->waktu_mulai === $model->waktu_selesai) {
                throw new \Exception('waktu mulai dan waktu selesai tidak boleh sama');
            }
        });
    }

    // ========== RELATIONS ==========

    public function profil()
    {
        return $this->belongsTo(Profil::class, 'id_profil', 'id');
    }

    public function buktiKegiatan()
    {
        return $this->hasMany(BuktiKegiatan::class, 'id_kegiatan', 'id');
    }
}
