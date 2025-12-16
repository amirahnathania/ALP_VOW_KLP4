<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class ProfilResource extends JsonResource
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
            'idUser' => $this->id_user,
            'idJabatan' => $this->id_jabatan,
            'createdAt' => $this->created_at?->toISOString(),
            'updatedAt' => $this->updated_at?->toISOString(),

            // Include relations if loaded
            'user' => $this->whenLoaded('user', function () {
                return new UserResource($this->user);
            }),
            'jabatan' => $this->whenLoaded('jabatan', function () {
                return new JabatanResource($this->jabatan);
            }),
        ];
    }
}
