<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class KegiatanResource extends JsonResource
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
            'jenisKegiatan' => $this->jenis_kegiatan,
            'idProfil' => $this->id_profil,
            'tanggalMulai' => $this->tanggal_mulai,
            'tanggalSelesai' => $this->tanggal_selesai,
            'waktuMulai' => $this->waktu_mulai,
            'waktuSelesai' => $this->waktu_selesai,
            'jenisPestisida' => $this->jenis_pestisida,
            'targetPenanaman' => $this->target_penanaman,
            'keterangan' => $this->keterangan,
            'createdAt' => $this->created_at?->toISOString(),
            'updatedAt' => $this->updated_at?->toISOString(),

            // Include profil if loaded
            'profil' => $this->whenLoaded('profil', function () {
                return new ProfilResource($this->profil);
            }),

            // Include bukti kegiatan count if loaded
            'buktiKegiatanCount' => $this->when(isset($this->bukti_kegiatan_count), $this->bukti_kegiatan_count),

            // Include persentase bukti if calculated
            'persentaseBukti' => $this->when(isset($this->persentase_bukti), $this->persentase_bukti),
        ];
    }
}
