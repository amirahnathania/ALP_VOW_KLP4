<?php

namespace App\Http\Requests;

use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Validation\Rule;

class StoreBuktiKegiatanRequest extends FormRequest
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
        if ($this->has('idKegiatan')) {
            $data['id_kegiatan'] = $this->input('idKegiatan');
        }
        if ($this->has('idProfil')) {
            $data['id_profil'] = $this->input('idProfil');
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
            'id_kegiatan' => [
                'required',
                Rule::exists('kegiatan', 'id')
            ],
            'id_profil' => [
                'required',
                Rule::exists('profil', 'id'),
                Rule::unique('bukti_kegiatan', 'id_profil')->where('id_kegiatan', $this->input('id_kegiatan'))
            ],
            'foto' => 'required|image|mimes:png,jpg,jpeg,svg,gif,webp|max:5120'
        ];
    }

    /**
     * Get custom messages for validator errors.
     *
     * @return array<string, string>
     */
    public function messages(): array
    {
        return [
            'id_kegiatan.required' => 'ID Kegiatan wajib diisi',
            'id_kegiatan.exists' => 'Kegiatan tidak ditemukan',
            'id_profil.required' => 'ID Profil wajib diisi',
            'id_profil.exists' => 'Profil tidak ditemukan',
            'id_profil.unique' => 'Profil ini sudah pernah mengirim bukti kegiatan. Satu profil hanya boleh mengirim 1 bukti per kegiatan.',
            'foto.required' => 'Anda harus mengirim file gambar',
            'foto.image' => 'File harus berupa gambar',
            'foto.mimes' => 'Format gambar harus: png, jpg, jpeg, svg, gif, atau webp',
            'foto.max' => 'Ukuran gambar tidak boleh lebih dari 5MB',
        ];
    }
}
