<?php

namespace App\Http\Controllers;

use App\Models\Kegiatan;
use App\Models\Profil;
use Illuminate\Http\Request;

class KegiatanController extends Controller
{
    /**
     * Validasi apakah id_profil memiliki jabatan "Ketua Gabungan Kelompok Tani"
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

        if ($profil->jabatan->jabatan !== 'Ketua Gabungan Kelompok Tani') {
            return [
                'valid' => false,
                'message' => 'Hanya Ketua Gabungan Kelompok Tani yang dapat membuat kegiatan. Jabatan saat ini: ' . $profil->jabatan->jabatan
            ];
        }

        return [
            'valid' => true,
            'message' => 'Validasi jabatan berhasil'
        ];
    }

    // GET /api/kegiatan
    public function index()
    {
        $totalKetuaProfileCount = Profil::whereHas('jabatan', function ($query) {
            $query->where('jabatan', 'Ketua Gabungan Kelompok Tani');
        })->count();

        $kegiatans = Kegiatan::with('profil')
            ->withCount('buktiKegiatan')
            ->get()
            ->map(function ($kegiatan) use ($totalKetuaProfileCount) {
                $persentase = $totalKetuaProfileCount > 0
                    ? ($kegiatan->bukti_kegiatan_count / $totalKetuaProfileCount) * 100
                    : 0;

                return array_merge($kegiatan->toArray(), [
                    'persentase_bukti' => round($persentase, 2)
                ]);
            });

        return response()->json([
            'success' => true,
            'message' => 'Daftar semua kegiatan',
            'data' => $kegiatans
        ]);
    }

    // POST /api/kegiatan
    public function store(Request $request)
    {
        $validated = $request->validate([
            'jenis_kegiatan' => 'required|string|max:255',
            'id_profil' => 'required|exists:profil,id',
            'tanggal_mulai' => 'required|date',
            'tanggal_selesai' => 'required|date',
            'waktu_mulai' => 'required|date_format:H:i:s',
            'waktu_selesai' => 'required|date_format:H:i:s',
            'jenis_pestisida' => 'nullable|string|max:255',
            'target_penanaman' => 'required|integer',
            'keterangan' => 'nullable|string',
        ]);

        if ($validated['waktu_mulai'] === $validated['waktu_selesai']) {
            return response()->json([
                'success' => false,
                'message' => 'Waktu mulai dan waktu selesai tidak boleh sama'
            ], 422);
        }

        $jabatanValidation = $this->validateProfilIsKetua($validated['id_profil']);
        if (!$jabatanValidation['valid']) {
            return response()->json([
                'success' => false,
                'message' => $jabatanValidation['message']
            ], 403);
        }

        $kegiatan = Kegiatan::create($validated);
        $kegiatan->load('profil');

        return response()->json([
            'success' => true,
            'message' => 'Kegiatan berhasil ditambah',
            'data' => $kegiatan
        ], 201);
    }

    // GET /api/kegiatan/{id}
    public function show($id)
    {
        $totalKetuaProfileCount = Profil::whereHas('jabatan', function ($query) {
            $query->where('jabatan', 'Ketua Gabungan Kelompok Tani');
        })->count();

        $kegiatan = Kegiatan::with('profil')
            ->withCount('buktiKegiatan')
            ->find($id);

        if (!$kegiatan) {
            return response()->json([
                'success' => false,
                'message' => 'Kegiatan tidak ditemukan'
            ], 404);
        }

        $persentase = $totalKetuaProfileCount > 0
            ? ($kegiatan->bukti_kegiatan_count / $totalKetuaProfileCount) * 100
            : 0;

        $data = array_merge($kegiatan->toArray(), [
            'persentase_bukti' => round($persentase, 2)
        ]);

        return response()->json([
            'success' => true,
            'data' => $data
        ]);
    }

    // PUT/PATCH /api/kegiatan/{id}
    public function update(Request $request, $id)
    {
        $kegiatan = Kegiatan::find($id);

        if (!$kegiatan) {
            return response()->json([
                'success' => false,
                'message' => 'Kegiatan tidak ditemukan'
            ], 404);
        }

        $jabatanValidation = $this->validateProfilIsKetua($kegiatan->id_profil);
        if (!$jabatanValidation['valid']) {
            return response()->json([
                'success' => false,
                'message' => 'Hanya Ketua Gabungan Kelompok Tani yang dapat mengubah kegiatan'
            ], 403);
        }

        $validated = $request->validate([
            'jenis_kegiatan' => 'sometimes|required|string|max:255',
            'id_profil' => 'sometimes|required|exists:profil,id',
            'tanggal_mulai' => 'sometimes|required|date',
            'tanggal_selesai' => 'sometimes|required|date',
            'waktu_mulai' => 'sometimes|required|date_format:H:i:s',
            'waktu_selesai' => 'sometimes|required|date_format:H:i:s',
            'jenis_pestisida' => 'nullable|string|max:255',
            'target_penanaman' => 'sometimes|required|integer',
            'keterangan' => 'nullable|string',
        ]);

        $waktuMulai = $validated['waktu_mulai'] ?? $kegiatan->waktu_mulai;
        $waktuSelesai = $validated['waktu_selesai'] ?? $kegiatan->waktu_selesai;

        if ($waktuMulai === $waktuSelesai) {
            return response()->json([
                'success' => false,
                'message' => 'Waktu mulai dan waktu selesai tidak boleh sama'
            ], 422);
        }

        if (isset($validated['id_profil']) && $validated['id_profil'] !== $kegiatan->id_profil) {
            $jabatanValidationNew = $this->validateProfilIsKetua($validated['id_profil']);
            if (!$jabatanValidationNew['valid']) {
                return response()->json([
                    'success' => false,
                    'message' => 'Hanya Ketua Gabungan Kelompok Tani yang dapat mengubah kegiatan'
                ], 403);
            }
        }

        $kegiatan->update($validated);
        $kegiatan->load('profil');

        return response()->json([
            'success' => true,
            'message' => 'Kegiatan berhasil diperbarui',
            'data' => $kegiatan
        ]);
    }

    // DELETE /api/kegiatan/{id}
    public function destroy($id)
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

    // GET /api/kegiatan/{id}/persentase-bukti
    public function getPersentaseBukti($id)
    {
        $totalKetuaProfileCount = Profil::whereHas('jabatan', function ($query) {
            $query->where('jabatan', 'Ketua Gabungan Kelompok Tani');
        })->count();

        $kegiatan = Kegiatan::withCount('buktiKegiatan')->find($id);

        if (!$kegiatan) {
            return response()->json([
                'success' => false,
                'message' => 'Kegiatan tidak ditemukan'
            ], 404);
        }

        $persentase = $totalKetuaProfileCount > 0
            ? ($kegiatan->bukti_kegiatan_count / $totalKetuaProfileCount) * 100
            : 0;

        return response()->json([
            'success' => true,
            'data' => [
                'persentase_bukti' => round($persentase, 2)
            ]
        ]);
    }
}
