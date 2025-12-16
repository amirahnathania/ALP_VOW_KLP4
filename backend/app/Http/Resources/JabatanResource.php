<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class JabatanResource extends JsonResource
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
            'jabatan' => $this->jabatan,
            'awalJabatan' => $this->awal_jabatan,
            'akhirJabatan' => $this->akhir_jabatan,
            'createdAt' => $this->created_at?->toISOString(),
            'updatedAt' => $this->updated_at?->toISOString(),

            // Include durasi if calculated
            'durasi' => $this->when(isset($this->durasi), $this->durasi),
            'status' => $this->when(isset($this->status), $this->status),
        ];
    }
}
