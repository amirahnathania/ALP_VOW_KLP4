<?php

namespace App\Http\Requests;

use Illuminate\Foundation\Http\FormRequest;

class UpdateKegiatanRequest extends FormRequest
{
    /**
     * Determine if the user is authorized to make this request.
     */
    public function authorize(): bool
    {
        return true;
    }

    /**
     * Prepare the data for validation.
     * Transform camelCase to snake_case
     */
    protected function prepareForValidation(): void
    {
        $data = [];

        // Transform camelCase to snake_case
        if ($this->has('jenisKegiatan')) {
            $data['jenis_kegiatan'] = $this->input('jenisKegiatan');
        }
        if ($this->has('idProfil')) {
            $data['id_profil'] = $this->input('idProfil');
        }
        if ($this->has('tanggalMulai')) {
            $data['tanggal_mulai'] = $this->input('tanggalMulai');
        }
        if ($this->has('tanggalSelesai')) {
            $data['tanggal_selesai'] = $this->input('tanggalSelesai');
        }
        if ($this->has('waktuMulai')) {
            $data['waktu_mulai'] = $this->input('waktuMulai');
        }
        if ($this->has('waktuSelesai')) {
            $data['waktu_selesai'] = $this->input('waktuSelesai');
        }
        if ($this->has('jenisPestisida')) {
            $data['jenis_pestisida'] = $this->input('jenisPestisida');
        }
        if ($this->has('targetPenanaman')) {
            $data['target_penanaman'] = $this->input('targetPenanaman');
        }

        $this->merge($data);
    }

    /**
     * Get the validation rules that apply to the request.
     *
     * @return array<string, \Illuminate\Contracts\Validation\ValidationRule|array<mixed>|string>
     */
    public function rules(): array
    {
        return [
            'jenis_kegiatan' => 'sometimes|required|string|max:255',
            // allow nullable so controller can resolve or leave unchanged
            'id_profil' => 'sometimes|nullable|exists:profil,id',
            'tanggal_mulai' => 'sometimes|required|date',
            'tanggal_selesai' => 'sometimes|required|date',
            'waktu_mulai' => 'sometimes|required|date_format:H:i:s',
            'waktu_selesai' => 'sometimes|required|date_format:H:i:s',
            'jenis_pestisida' => 'nullable|string|max:255',
            'target_penanaman' => 'sometimes|required|integer',
            'keterangan' => 'nullable|string',
        ];
    }
}
