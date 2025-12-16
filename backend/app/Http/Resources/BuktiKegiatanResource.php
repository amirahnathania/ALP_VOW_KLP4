<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class BuktiKegiatanResource extends JsonResource
{
    /**
     * Transform the resource into an array.
     *
     * @return array<string, mixed>
     */
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'idKegiatan' => $this->id_kegiatan,
            'idProfil' => $this->id_profil,
            'namaFoto' => $this->nama_foto,
            'tipeFoto' => $this->tipe_foto,
            'imageUrl' => $this->image_url,
            'createdAt' => $this->created_at?->toISOString(),
            'updatedAt' => $this->updated_at?->toISOString(),

            // Include relations if loaded
            'kegiatan' => $this->whenLoaded('kegiatan', function () {
                return new KegiatanResource($this->kegiatan);
            }),
            'profil' => $this->whenLoaded('profil', function () {
                return new ProfilResource($this->profil);
            }),

            // Include extra fields if present
            'namaPengguna' => $this->when(isset($this->nama_pengguna), $this->nama_pengguna),
            'jabatan' => $this->when(isset($this->jabatan), $this->jabatan),
            'jenisKegiatan' => $this->when(isset($this->jenis_kegiatan), $this->jenis_kegiatan),
        ];
    }
}
