<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class BuktiKegiatan extends Model
{
    protected $primaryKey = 'id';
    protected $table = 'bukti_kegiatans';

    protected $fillable = [
        'Id_Kegiatan',
        'Id_Profil',
        'Bukti_Foto',
        'mime_type',
    ];

    /**
     * Get validation rules for photo files
     */
    public static function photoValidationRules()
    {
        return [
            'Bukti_Foto' => 'required|image|mimes:jpeg,jpg,png,gif,svg|max:5120', // max 5MB
        ];
    }

    /**
     * BuktiKegiatan dimiliki oleh 1 Kegiatan
     */
    public function kegiatan()
    {
        return $this->belongsTo(Kegiatan::class, 'Id_Kegiatan');
    }

    /**
     * BuktiKegiatan dimiliki oleh 1 Profil
     */
    public function profil()
    {
        return $this->belongsTo(Profil::class, 'Id_Profil');
    }
}
