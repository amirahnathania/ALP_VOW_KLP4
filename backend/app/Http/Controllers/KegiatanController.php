<?php

namespace App\Http\Controllers;

use App\Models\Kegiatan;
use App\Models\Profil;
use Illuminate\Http\Request;

class KegiatanController extends Controller
{
    /**
     * Validasi apakah Id_Profil memiliki jabatan "Ketua Gabungan Kelompok Tani"
     */
    private function validateProfilIsKetua($idProfil)
    {
        $profil = Profil::with('jabatan')->find($idProfil);
        
        if (!$profil) {
            return [
                'valid' => false,
                'message' => 'Profil tidak ditemukan'
            ];
        }

        if (!$profil->jabatan) {
            return [
                'valid' => false,
                'message' => 'Profil tidak memiliki jabatan'
            ];
        }

        // Cek apakah jabatan adalah "Ketua Gabungan Kelompok Tani"
        if ($profil->jabatan->Jabatan !== 'Ketua Gabungan Kelompok Tani') {
            return [
                'valid' => false,
                'message' => 'Hanya Ketua Gabungan Kelompok Tani yang dapat membuat kegiatan. Jabatan saat ini: ' . $profil->jabatan->Jabatan
            ];
        }

        return [
            'valid' => true,
            'message' => 'Validasi jabatan berhasil'
        ];
    }
    /**
     * Display a listing of the resource.
     */
    public function index()
    {
        $kegiatans = Kegiatan::with('profil')->get();
        return response()->json([
            'success' => true,
            'message' => 'Daftar semua kegiatan',
            'data' => $kegiatans
        ]);
    }

    /**
     * Store a newly created resource in storage.
     */
    public function store(Request $request)
    {
        // Validasi awal
        $initialValidation = $request->validate([
            'Jenis_Kegiatan' => 'required|string|max:255',
            'Id_Profil' => 'required|exists:profil,Id_Profil',
            'Tanggal_Mulai' => 'required|date',
            'Tanggal_Selesai' => 'required|date|after_or_equal:Tanggal_Mulai',
            'Waktu_Mulai' => 'required|date_format:H:i:s',
            'Waktu_Selesai' => 'required|date_format:H:i:s',
            'Jenis_Pestisida' => 'nullable|string|max:255',
            'Target_Penanaman' => 'nullable|integer',
            'Keterangan' => 'nullable|string',
        ]);

        // Validasi conditional berdasarkan Jenis_Kegiatan
        $jenisKegiatan = strtolower(trim($initialValidation['Jenis_Kegiatan']));

        if (strpos($jenisKegiatan, 'penanaman') !== false) {
            // Jika mengandung "penanaman": Jenis_Pestisida nullable, Target_Penanaman WAJIB
            $Validated = $request->validate([
                'Jenis_Kegiatan' => 'required|string|max:255',
                'Id_Profil' => 'required|exists:profil,Id_Profil',
                'Tanggal_Mulai' => 'required|date',
                'Tanggal_Selesai' => 'required|date|after_or_equal:Tanggal_Mulai',
                'Waktu_Mulai' => 'required|date_format:H:i:s',
                'Waktu_Selesai' => 'required|date_format:H:i:s',
                'Jenis_Pestisida' => 'nullable|string|max:255',
                'Target_Penanaman' => 'required|integer|min:1',
                'Keterangan' => 'nullable|string',
            ], [
                'Target_Penanaman.required' => 'Target penanaman harus diisi untuk kegiatan penanaman',
                'Target_Penanaman.min' => 'Target penanaman minimal 1',
            ]);
        } elseif (strpos($jenisKegiatan, 'penyemprotan') !== false) {
            // Jika mengandung "penyemprotan": Target_Penanaman nullable, Jenis_Pestisida WAJIB
            $Validated = $request->validate([
                'Jenis_Kegiatan' => 'required|string|max:255',
                'Id_Profil' => 'required|exists:profil,Id_Profil',
                'Tanggal_Mulai' => 'required|date',
                'Tanggal_Selesai' => 'required|date|after_or_equal:Tanggal_Mulai',
                'Waktu_Mulai' => 'required|date_format:H:i:s',
                'Waktu_Selesai' => 'required|date_format:H:i:s',
                'Jenis_Pestisida' => 'required|string|max:255',
                'Target_Penanaman' => 'nullable|integer',
                'Keterangan' => 'nullable|string',
            ], [
                'Jenis_Pestisida.required' => 'Jenis pestisida harus diisi untuk kegiatan penyemprotan',
            ]);
        } elseif (strpos($jenisKegiatan, 'pemupukan') !== false) {
            // Jika mengandung "pemupukan": Jenis_Pestisida nullable, Target_Penanaman nullable, Keterangan WAJIB
            $Validated = $request->validate([
                'Jenis_Kegiatan' => 'required|string|max:255',
                'Id_Profil' => 'required|exists:profil,Id_Profil',
                'Tanggal_Mulai' => 'required|date',
                'Tanggal_Selesai' => 'required|date|after_or_equal:Tanggal_Mulai',
                'Waktu_Mulai' => 'required|date_format:H:i:s',
                'Waktu_Selesai' => 'required|date_format:H:i:s',
                'Jenis_Pestisida' => 'nullable|string|max:255',
                'Target_Penanaman' => 'nullable|integer',
                'Keterangan' => 'required|string',
            ], [
                'Keterangan.required' => 'Keterangan harus diisi untuk kegiatan pemupukan',
            ]);
        } else {
            // Untuk jenis kegiatan lain: kedua field optional
            $Validated = $initialValidation;
        }

        // Validasi: Waktu_Mulai dan Waktu_Selesai tidak boleh sama
        if ($Validated['Waktu_Mulai'] === $Validated['Waktu_Selesai']) {
            return response()->json([
                'success' => false,
                'message' => 'Waktu mulai dan waktu selesai tidak boleh sama'
            ], 422);
        }

        // Validasi jabatan: hanya Ketua Gabungan Kelompok Tani yang dapat membuat kegiatan
        $jabatanValidation = $this->validateProfilIsKetua($Validated['Id_Profil']);
        if (!$jabatanValidation['valid']) {
            return response()->json([
                'success' => false,
                'message' => $jabatanValidation['message']
            ], 403);
        }

        $kegiatan = Kegiatan::create($Validated);
        $kegiatan->load('profil');
        return response()->json([
            'success' => true,
            'message' => 'Kegiatan berhasil ditambah',
            'data' => $kegiatan
        ], 201);
    }

    /**
     * Display the specified resource.
     */
    public function show($id)
    {
        $kegiatan = Kegiatan::with('profil')->find($id);
        
        if (!$kegiatan) {
            return response()->json([
                'success' => false,
                'message' => 'Id_Kegiatan tidak ditemukan'
            ], 404);
        }

        return response()->json([
            'success' => true,
            'data' => $kegiatan
        ]);
    }

    /**
     * Update the specified resource in storage.
     */
    public function update(Request $request, $id)
    {
        // Cari kegiatan berdasarkan ID
        $kegiatan = Kegiatan::find($id);
        
        if (!$kegiatan) {
            return response()->json([
                'success' => false,
                'message' => 'Id_Kegiatan tidak ditemukan'
            ], 404);
        }

        // Validasi: hanya Ketua yang bisa update kegiatan
        $jabatanValidation = $this->validateProfilIsKetua($kegiatan->Id_Profil);
        if (!$jabatanValidation['valid']) {
            return response()->json([
                'success' => false,
                'message' => 'Hanya Ketua Gabungan Kelompok Tani yang dapat mengubah kegiatan'
            ], 403);
        }

        // Validasi awal untuk menentukan Jenis_Kegiatan
        $jenisKegiatan = strtolower(trim($request->input('Jenis_Kegiatan') ?? $kegiatan->Jenis_Kegiatan));

        if (strpos($jenisKegiatan, 'penanaman') !== false) {
            // Jika mengandung "penanaman": Jenis_Pestisida nullable, Target_Penanaman WAJIB
            $Validated = $request->validate([
                'Jenis_Kegiatan' => 'sometimes|required|string|max:255',
                'Id_Profil' => 'required|exists:profil,Id_Profil',
                'Tanggal_Mulai' => 'sometimes|required|date',
                'Tanggal_Selesai' => 'sometimes|required|date|after_or_equal:Tanggal_Mulai',
                'Waktu_Mulai' => 'sometimes|required|date_format:H:i:s',
                'Waktu_Selesai' => 'sometimes|required|date_format:H:i:s',
                'Jenis_Pestisida' => 'nullable|string|max:255',
                'Target_Penanaman' => 'required|integer|min:1',
                'Keterangan' => 'nullable|string',
            ], [
                'Target_Penanaman.required' => 'Target penanaman harus diisi untuk kegiatan penanaman',
                'Target_Penanaman.min' => 'Target penanaman minimal 1',
            ]);
        } elseif (strpos($jenisKegiatan, 'penyemprotan') !== false) {
            // Jika mengandung "penyemprotan": Target_Penanaman nullable, Jenis_Pestisida WAJIB
            $Validated = $request->validate([
                'Jenis_Kegiatan' => 'sometimes|required|string|max:255',
                'Id_Profil' => 'required|exists:profil,Id_Profil',
                'Tanggal_Mulai' => 'sometimes|required|date',
                'Tanggal_Selesai' => 'sometimes|required|date|after_or_equal:Tanggal_Mulai',
                'Waktu_Mulai' => 'sometimes|required|date_format:H:i:s',
                'Waktu_Selesai' => 'sometimes|required|date_format:H:i:s',
                'Jenis_Pestisida' => 'required|string|max:255',
                'Target_Penanaman' => 'nullable|integer',
                'Keterangan' => 'nullable|string',
            ], [
                'Jenis_Pestisida.required' => 'Jenis pestisida harus diisi untuk kegiatan penyemprotan',
            ]);
        } elseif (strpos($jenisKegiatan, 'pemupukan') !== false) {
            // Jika mengandung "pemupukan": Jenis_Pestisida nullable, Target_Penanaman nullable, Keterangan WAJIB
            $Validated = $request->validate([
                'Jenis_Kegiatan' => 'sometimes|required|string|max:255',
                'Id_Profil' => 'required|exists:profil,Id_Profil',
                'Tanggal_Mulai' => 'sometimes|required|date',
                'Tanggal_Selesai' => 'sometimes|required|date|after_or_equal:Tanggal_Mulai',
                'Waktu_Mulai' => 'sometimes|required|date_format:H:i:s',
                'Waktu_Selesai' => 'sometimes|required|date_format:H:i:s',
                'Jenis_Pestisida' => 'nullable|string|max:255',
                'Target_Penanaman' => 'nullable|integer',
                'Keterangan' => 'required|string',
            ], [
                'Keterangan.required' => 'Keterangan harus diisi untuk kegiatan pemupukan',
            ]);
        } else {
            // Untuk jenis kegiatan lain: kedua field optional
            $Validated = $request->validate([
                'Jenis_Kegiatan' => 'sometimes|required|string|max:255',
                'Id_Profil' => 'required|exists:profil,Id_Profil',
                'Tanggal_Mulai' => 'sometimes|required|date',
                'Tanggal_Selesai' => 'sometimes|required|date|after_or_equal:Tanggal_Mulai',
                'Waktu_Mulai' => 'sometimes|required|date_format:H:i:s',
                'Waktu_Selesai' => 'sometimes|required|date_format:H:i:s',
                'Jenis_Pestisida' => 'nullable|string|max:255',
                'Target_Penanaman' => 'nullable|integer',
                'Keterangan' => 'nullable|string',
            ]);
        }

        // Validasi: Waktu_Mulai dan Waktu_Selesai tidak boleh sama (jika kedua field ada di request)
        if (isset($Validated['Waktu_Mulai']) && isset($Validated['Waktu_Selesai']) && 
            $Validated['Waktu_Mulai'] === $Validated['Waktu_Selesai']) {
            return response()->json([
                'success' => false,
                'message' => 'Waktu mulai dan waktu selesai tidak boleh sama'
            ], 422);
        }

        // Jika Id_Profil diubah, validasi jabatan profil baru
        if (isset($Validated['Id_Profil']) && $Validated['Id_Profil'] !== $kegiatan->Id_Profil) {
            $jabatanValidationNew = $this->validateProfilIsKetua($Validated['Id_Profil']);
            if (!$jabatanValidationNew['valid']) {
                return response()->json([
                    'success' => false,
                    'message' => 'Hanya Ketua Gabungan Kelompok Tani yang dapat mengubah kegiatan'
                ], 403);
            }
        }

        $kegiatan->update($Validated);
        $kegiatan->load('profil');
        return response()->json([
            'success' => true,
            'message' => 'Kegiatan berhasil diperbarui',
            'data' => $kegiatan
        ]);
    }

    /**
     * Remove the specified resource from storage.
     */
    public function destroy(string $id)
    {
        $kegiatan = Kegiatan::find($id);
        if (!$kegiatan) {
            return response()->json([
                'success' => false,
                'message' => 'Kegiatan tidak ditemukan'
            ], 404);
        }

        $kegiatan->delete();
        return response()->json([
            'success' => true,
            'message' => 'Kegiatan berhasil dihapus'
        ]);
    }

    /**
     * Get semua kegiatan yang dibuat oleh Ketua Gabungan Kelompok Tani
     */
    public function getByKetua()
    {
        $kegiatans = Kegiatan::whereHas('profil.jabatan', function ($query) {
            $query->where('Jabatan', 'Ketua Gabungan Kelompok Tani');
        })->with('profil')->get();

        return response()->json([
            'success' => true,
            'message' => 'Daftar kegiatan yang dibuat oleh Ketua Gabungan Kelompok Tani',
            'data' => $kegiatans
        ]);
    }

    /**
     * Verifikasi apakah profil memiliki jabatan Ketua Gabungan Kelompok Tani
     */
    public function verifyKetuaJabatan($idProfil)
    {
        $validation = $this->validateProfilIsKetua($idProfil);
        
        return response()->json([
            'success' => $validation['valid'],
            'message' => $validation['message']
        ], $validation['valid'] ? 200 : 403);
    }
}