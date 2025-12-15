<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class BuktiKegiatan extends Model
{
    protected $primaryKey = 'id';
    protected $table = 'bukti_kegiatan';

    protected $fillable = [
        'id_kegiatan',
        'id_profil',
        'nama_foto',
        'tipe_foto',
    ];

    protected $casts = [
        'id' => 'integer',
        'id_kegiatan' => 'integer',
        'id_profil' => 'integer',
        'created_at' => 'datetime',
        'updated_at' => 'datetime',
    ];

    /**
     * Allowed image extensions
     */
    public static function allowedExtensions()
    {
        return ['png', 'jpg', 'jpeg', 'svg', 'gif', 'webp'];
    }

    /**
     * Allowed MIME types
     */
    public static function allowedMimeTypes()
    {
        return [
            'image/png',
            'image/jpg',
            'image/jpeg',
            'image/svg+xml',
            'image/gif',
            'image/webp',
        ];
    }

    /**
     * Get validation rules for photo files
     */
    public static function photoValidationRules()
    {
        return [
            'foto' => 'required|image|mimes:png,jpg,jpeg,svg,gif,webp|max:5120', // max 5MB
        ];
    }

    /**
     * Get the full path to the image file
     */
    public function getImagePathAttribute()
    {
        return public_path('images/' . $this->nama_foto);
    }

    /**
     * Get the URL to access the image
     */
    public function getImageUrlAttribute()
    {
        return url('images/' . $this->nama_foto);
    }

    // ========== RELATIONS ==========

    public function kegiatan()
    {
        return $this->belongsTo(Kegiatan::class, 'id_kegiatan', 'id');
    }

    public function profil()
    {
        return $this->belongsTo(Profil::class, 'id_profil', 'id');
    }
}
