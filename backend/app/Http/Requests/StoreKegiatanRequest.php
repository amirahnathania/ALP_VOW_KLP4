<?php

namespace App\Http\Requests;

use Illuminate\Foundation\Http\FormRequest;

class StoreKegiatanRequest extends FormRequest
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
            'jenis_kegiatan' => 'required|string|max:255',
            // allow nullable here so controller can resolve id_profil from auth or email fallback
            'id_profil' => 'nullable|exists:profil,id',
            'tanggal_mulai' => 'required|date',
            'tanggal_selesai' => 'required|date',
            'waktu_mulai' => 'required|date_format:H:i:s',
            'waktu_selesai' => 'required|date_format:H:i:s',
            'jenis_pestisida' => 'nullable|string|max:255',
            'target_penanaman' => 'required|integer',
            'keterangan' => 'nullable|string',
        ];
    }
}
