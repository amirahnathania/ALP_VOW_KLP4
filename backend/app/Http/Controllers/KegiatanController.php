<?php

namespace App\Http\Controllers;

use App\Models\Kegiatan;
use App\Models\Profil;
use Illuminate\Http\Request;
use App\Http\Requests\StoreKegiatanRequest;
use App\Http\Requests\UpdateKegiatanRequest;
use App\Http\Resources\KegiatanResource;

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

                $kegiatan->persentase_bukti = round($persentase, 2);
                return $kegiatan;
            });

        return response()->json([
            'success' => true,
            'message' => 'Daftar semua kegiatan',
            'data' => KegiatanResource::collection($kegiatans)
        ]);
    }

    // POST /api/kegiatan
    public function store(StoreKegiatanRequest $request)
    {
        $validated = $request->validated();

        // Resolve id_profil from authenticated user or from provided email if possible.
        // This lets clients omit idProfil and rely on auth token or email.
        $idProfilResolved = null;
        try {
            $authUser = $request->user();
            if ($authUser) {
                $profil = Profil::where('id_user', $authUser->id)->first();
                if (!$profil) {
                    // create profil using an active or fallback jabatan
                    $jabatan = \App\Models\Jabatan::aktif()->first() ?? \App\Models\Jabatan::first();
                    if (!$jabatan) {
                        $jabatan = \App\Models\Jabatan::create([
                            'jabatan' => 'Anggota Sementara',
                            'awal_jabatan' => now()->format('Y-m-d'),
                            'akhir_jabatan' => null,
                        ]);
                    }
                    $profil = Profil::create([
                        'id_user' => $authUser->id,
                        'id_jabatan' => $jabatan->id,
                    ]);
                }
                $idProfilResolved = $profil->id;
            } elseif ($request->filled('email')) {
                $user = \App\Models\User::where('email', $request->input('email'))->first();
                if ($user) {
                    $profil = Profil::firstOrCreate([
                        'id_user' => $user->id,
                    ], [
                        'id_jabatan' => (\App\Models\Jabatan::aktif()->first() ?? \App\Models\Jabatan::first())->id ?? 1,
                    ]);
                    $idProfilResolved = $profil->id;
                }
            }
        } catch (\Exception $e) {
            // ignore and fall back to provided id_profil if any
        }

        if ($idProfilResolved !== null) {
            $validated['id_profil'] = $idProfilResolved;
        }


        if ($validated['waktu_mulai'] === $validated['waktu_selesai']) {
            return response()->json([
                'success' => false,
                'message' => 'Waktu mulai dan waktu selesai tidak boleh sama'
            ], 422);
        }

        // Allow the authenticated user to create kegiatan for their own profil
        $profilForValidation = Profil::find($validated['id_profil']);
        if ($profilForValidation) {
            $authUser = $request->user();
            $allow = false;
            if ($authUser && $profilForValidation->id_user == $authUser->id) {
                // Owner may create kegiatan for themselves even if not Ketua
                $allow = true;
            }
            if (!$allow) {
                $jabatanValidation = $this->validateProfilIsKetua($validated['id_profil']);
                if (!$jabatanValidation['valid']) {
                    return response()->json([
                        'success' => false,
                        'message' => $jabatanValidation['message']
                    ], 403);
                }
            }
        }

        $kegiatan = Kegiatan::create($validated);
        $kegiatan->load('profil');

        return response()->json([
            'success' => true,
            'message' => 'Kegiatan berhasil ditambah',
            'data' => new KegiatanResource($kegiatan)
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

        $kegiatan->persentase_bukti = round($persentase, 2);

        return response()->json([
            'success' => true,
            'data' => new KegiatanResource($kegiatan)
        ]);
    }

    // PUT/PATCH /api/kegiatan/{id}
    public function update(UpdateKegiatanRequest $request, $id)
    {
        $kegiatan = Kegiatan::find($id);

        if (!$kegiatan) {
            return response()->json([
                'success' => false,
                'message' => 'Kegiatan tidak ditemukan'
            ], 404);
        }

        // Allow the authenticated owner of the kegiatan to update it even if not Ketua
        $authUser = $request->user();
        $allowUpdate = false;
        try {
            if ($authUser && $kegiatan->profil && $kegiatan->profil->id_user == $authUser->id) {
                $allowUpdate = true;
            }
        } catch (\Exception $e) {
            // ignore and fall through to validation
        }

        if (!$allowUpdate) {
            $jabatanValidation = $this->validateProfilIsKetua($kegiatan->id_profil);
            if (!$jabatanValidation['valid']) {
                return response()->json([
                    'success' => false,
                    'message' => 'Hanya Ketua Gabungan Kelompok Tani yang dapat mengubah kegiatan'
                ], 403);
            }
        }

        $validated = $request->validated();


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
            'data' => new KegiatanResource($kegiatan)
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

        // Delete related bukti_kegiatan and their image files first to avoid FK constraint errors
        try {
            $bukits = $kegiatan->buktiKegiatan()->get();
            foreach ($bukits as $bukti) {
                try {
                    $imagePath = $bukti->image_path ?? null;
                    if ($imagePath && file_exists($imagePath)) {
                        @unlink($imagePath);
                    }
                } catch (\Exception $e) {
                    // ignore file deletion errors
                }
                try {
                    $bukti->delete();
                } catch (\Exception $e) {
                    // ignore individual delete errors and continue
                }
            }

            $kegiatan->delete();

            return response()->json([
                'success' => true,
                'message' => 'Kegiatan berhasil dihapus'
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Gagal menghapus kegiatan: ' . $e->getMessage()
            ], 500);
        }
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
