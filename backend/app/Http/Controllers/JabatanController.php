<?php

namespace App\Http\Controllers;

use App\Models\Jabatan;
use App\Http\Requests\JabatanRequest;
use App\Http\Resources\JabatanResource;
use Illuminate\Http\Request;
use Carbon\Carbon;

class JabatanController extends Controller
{
    // GET /api/jabatan
    public function index()
    {
        try {
            $jabatan = Jabatan::all();
            return response()->json([
                'success' => true,
                'data' => JabatanResource::collection($jabatan),
                'count' => $jabatan->count()
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Gagal mengambil data jabatan',
                'error' => $e->getMessage()
            ], 500);
        }
    }

    // POST /api/jabatan
    public function store(Request $request)
    {
        $validated = $request->validate([
            'jabatan' => [
                'required',
                'string',
                'min:3',
                'max:50',
                'regex:/^[a-zA-Z\s]+$/'
            ],
            'awal_jabatan' => [
                'required',
                'date',
                'date_format:Y-m-d'
            ],
            'akhir_jabatan' => [
                'required',
                'date',
                'date_format:Y-m-d'
            ]
        ], [
            'jabatan.required' => 'Nama jabatan wajib diisi',
            'jabatan.min' => 'Nama jabatan minimal 3 karakter',
            'jabatan.max' => 'Nama jabatan maksimal 50 karakter',
            'jabatan.regex' => 'Nama jabatan hanya boleh mengandung huruf dan spasi',

            'awal_jabatan.required' => 'Tanggal awal jabatan wajib diisi',
            'awal_jabatan.date' => 'Format tanggal awal tidak valid',
            'awal_jabatan.date_format' => 'Format tanggal awal harus YYYY-MM-DD',

            'akhir_jabatan.required' => 'Tanggal akhir jabatan wajib diisi',
            'akhir_jabatan.date' => 'Format tanggal akhir tidak valid',
            'akhir_jabatan.date_format' => 'Format tanggal akhir harus YYYY-MM-DD'
        ]);

        try {
            $awal = Carbon::createFromFormat('Y-m-d', $validated['awal_jabatan'])->startOfDay();
            $akhir = Carbon::createFromFormat('Y-m-d', $validated['akhir_jabatan'])->endOfDay();

            if ($awal->greaterThan($akhir)) {
                return response()->json([
                    'success' => false,
                    'message' => 'Tanggal awal harus sebelum atau sama dengan tanggal akhir'
                ], 422);
            }

            $diff = $akhir->diff($awal);
            $totalHari = $diff->days;

            if ($totalHari < 365) {
                return response()->json([
                    'success' => false,
                    'message' => 'Durasi jabatan minimal 1 tahun'
                ], 422);
            }

            if ($totalHari > 1460) {
                return response()->json([
                    'success' => false,
                    'message' => 'Durasi jabatan maksimal 4 tahun'
                ], 422);
            }

            $maxTahun = Carbon::now()->addYears(5);
            if ($akhir->greaterThan($maxTahun)) {
                return response()->json([
                    'success' => false,
                    'message' => 'Tanggal akhir tidak boleh lebih dari 5 tahun ke depan'
                ], 422);
            }

            $existingJabatan = Jabatan::where('jabatan', $validated['jabatan'])
                ->where(function ($query) use ($awal, $akhir) {
                    $query->whereBetween('awal_jabatan', [$awal, $akhir])
                        ->orWhereBetween('akhir_jabatan', [$awal, $akhir])
                        ->orWhere(function ($q) use ($awal, $akhir) {
                            $q->where('awal_jabatan', '<=', $awal)
                                ->where('akhir_jabatan', '>=', $akhir);
                        });
                })
                ->first();

            if ($existingJabatan) {
                return response()->json([
                    'success' => false,
                    'message' => 'Jabatan dengan nama ini sudah ada dalam periode yang tumpang tindih'
                ], 409);
            }

            $jabatan = Jabatan::create($validated);

            $jabatan->durasi = [
                'tahun' => $diff->y,
                'bulan' => $diff->m,
                'hari' => $diff->d,
                'total_hari' => $totalHari
            ];

            return response()->json([
                'success' => true,
                'message' => 'Jabatan berhasil dibuat',
                'data' => new JabatanResource($jabatan)
            ], 201);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Gagal membuat jabatan',
                'error' => $e->getMessage()
            ], 500);
        }
    }

    // GET /api/jabatan/{id}
    public function show($id)
    {
        try {
            $jabatan = Jabatan::find($id);

            if (!$jabatan) {
                return response()->json([
                    'success' => false,
                    'message' => 'Jabatan tidak ditemukan'
                ], 404);
            }

            $awal = Carbon::parse($jabatan->awal_jabatan);
            $akhir = Carbon::parse($jabatan->akhir_jabatan);
            $diff = $akhir->diff($awal);

            $jabatan->durasi = [
                'tahun' => $diff->y,
                'bulan' => $diff->m,
                'hari' => $diff->d,
                'total_hari' => $diff->days
            ];
            $jabatan->status = $this->getStatusJabatan($awal, $akhir);

            return response()->json([
                'success' => true,
                'data' => new JabatanResource($jabatan)
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Gagal mengambil data jabatan',
                'error' => $e->getMessage()
            ], 500);
        }
    }

    // PUT/PATCH /api/jabatan/{id}
    public function update(Request $request, $id)
    {
        try {
            $jabatan = Jabatan::find($id);

            if (!$jabatan) {
                return response()->json([
                    'success' => false,
                    'message' => 'Jabatan tidak ditemukan'
                ], 404);
            }

            $validated = $request->validate([
                'jabatan' => [
                    'sometimes',
                    'required',
                    'string',
                    'min:3',
                    'max:50',
                    'regex:/^[a-zA-Z\s]+$/'
                ],
                'awal_jabatan' => [
                    'sometimes',
                    'required',
                    'date',
                    'date_format:Y-m-d'
                ],
                'akhir_jabatan' => [
                    'sometimes',
                    'required',
                    'date',
                    'date_format:Y-m-d'
                ]
            ]);

            if ($request->has('awal_jabatan') || $request->has('akhir_jabatan')) {
                $awal = $request->has('awal_jabatan')
                    ? Carbon::createFromFormat('Y-m-d', $validated['awal_jabatan'])->startOfDay()
                    : Carbon::parse($jabatan->awal_jabatan)->startOfDay();

                $akhir = $request->has('akhir_jabatan')
                    ? Carbon::createFromFormat('Y-m-d', $validated['akhir_jabatan'])->endOfDay()
                    : Carbon::parse($jabatan->akhir_jabatan)->endOfDay();

                if ($awal->greaterThan($akhir)) {
                    return response()->json([
                        'success' => false,
                        'message' => 'Tanggal awal harus sebelum atau sama dengan tanggal akhir'
                    ], 422);
                }

                $diff = $akhir->diff($awal);
                $totalHari = $diff->days;

                if ($totalHari < 365) {
                    return response()->json([
                        'success' => false,
                        'message' => 'Durasi jabatan minimal 1 tahun'
                    ], 422);
                }

                if ($totalHari > 1460) {
                    return response()->json([
                        'success' => false,
                        'message' => 'Durasi jabatan maksimal 4 tahun'
                    ], 422);
                }
            }

            $jabatan->update($validated);

            return response()->json([
                'success' => true,
                'message' => 'Jabatan berhasil diperbarui',
                'data' => $jabatan
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Gagal mengupdate jabatan',
                'error' => $e->getMessage()
            ], 500);
        }
    }

    // DELETE /api/jabatan/{id}
    public function destroy($id)
    {
        try {
            $jabatan = Jabatan::find($id);

            if (!$jabatan) {
                return response()->json([
                    'success' => false,
                    'message' => 'Jabatan tidak ditemukan'
                ], 404);
            }

            if ($jabatan->profil()->count() > 0) {
                return response()->json([
                    'success' => false,
                    'message' => 'Jabatan memiliki profil terkait. Tidak dapat dihapus.'
                ], 400);
            }

            $jabatan->delete();

            return response()->json([
                'success' => true,
                'message' => 'Jabatan berhasil dihapus'
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Gagal menghapus jabatan',
                'error' => $e->getMessage()
            ], 500);
        }
    }

    private function getStatusJabatan($awal, $akhir)
    {
        $today = Carbon::now();

        if ($today->lessThan($awal)) {
            return 'akan_datang';
        }

        if ($today->greaterThan($akhir)) {
            return 'selesai';
        }

        return 'aktif';
    }
}
