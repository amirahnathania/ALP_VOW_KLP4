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
        $name = $this->nama_foto ?? '';
        $type = $this->tipe_foto ?? '';

        // If nama_foto already contains an extension, use it as-is
        if (str_contains($name, '.')) {
            $filename = $name;
        } else {
            // If tipe_foto contains a mime (image/webp), convert to extension
            if (str_starts_with($type, 'image/')) {
                $ext = '.' . explode('/', $type)[1];
            } else {
                $ext = $type; // assume already like '.webp'
            }
            $filename = $name . $ext;
        }

        return public_path('images/' . $filename);
    }

    /**
     * Get the URL to access the image
     */
    public function getImageUrlAttribute()
    {
        $name = $this->nama_foto ?? '';
        $type = $this->tipe_foto ?? '';

        if (str_contains($name, '.')) {
            $filename = $name;
        } else {
            if (str_starts_with($type, 'image/')) {
                $ext = '.' . explode('/', $type)[1];
            } else {
                $ext = $type;
            }
            $filename = $name . $ext;
        }

        return url('images/' . $filename);
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
