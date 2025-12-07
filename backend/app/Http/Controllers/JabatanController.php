<?php

namespace App\Http\Controllers;

use App\Models\Jabatan;
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
                'data' => $jabatan,
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
        // Validasi data input dasar
        $validated = $request->validate([
            'Jabatan' => [
                'required',
                'string',
                'min:3',
                'max:50',
                'regex:/^[a-zA-Z\s]+$/'
            ],
            'Awal_jabatan' => [
                'required',
                'date',
                'date_format:Y-m-d'
            ],
            'Akhir_jabatan' => [
                'required',
                'date',
                'date_format:Y-m-d'
            ]
        ], [
            'Jabatan.required' => 'Nama jabatan wajib diisi',
            'Jabatan.min' => 'Nama jabatan minimal 3 karakter',
            'Jabatan.max' => 'Nama jabatan maksimal 50 karakter',
            'Jabatan.regex' => 'Nama jabatan hanya boleh mengandung huruf dan spasi',
            
            'Awal_jabatan.required' => 'Tanggal awal jabatan wajib diisi',
            'Awal_jabatan.date' => 'Format tanggal awal tidak valid',
            'Awal_jabatan.date_format' => 'Format tanggal awal harus YYYY-MM-DD',
            
            'Akhir_jabatan.required' => 'Tanggal akhir jabatan wajib diisi',
            'Akhir_jabatan.date' => 'Format tanggal akhir tidak valid',
            'Akhir_jabatan.date_format' => 'Format tanggal akhir harus YYYY-MM-DD'
        ]);

        try {
            // Parse tanggal dengan format EXPLICIT
            $awal = Carbon::createFromFormat('Y-m-d', $validated['Awal_jabatan'])->startOfDay();
            $akhir = Carbon::createFromFormat('Y-m-d', $validated['Akhir_jabatan'])->endOfDay();
            
            // DEBUG: Log untuk troubleshooting
            \Log::info('JABATAN CREATE DEBUG', [
                'input' => $validated,
                'parsed_awal' => $awal->toDateTimeString(),
                'parsed_akhir' => $akhir->toDateTimeString(),
                'diff_in_days' => $akhir->diffInDays($awal),
                'diff_in_days_manual' => $akhir->diff($awal)->days,
                'is_awal_before_akhir' => $awal->lessThanOrEqualTo($akhir)
            ]);
            
            // Validasi: Awal harus <= Akhir
            if ($awal->greaterThan($akhir)) {
                return response()->json([
                    'success' => false,
                    'message' => 'Tanggal awal harus sebelum atau sama dengan tanggal akhir',
                    'debug' => [
                        'awal' => $awal->toDateString(),
                        'akhir' => $akhir->toDateString(),
                        'comparison' => $awal->greaterThan($akhir)
                    ]
                ], 422);
            }
            
            // Hitung total hari dengan CARA YANG BENAR
            // Gunakan diff()->days untuk hasil yang lebih reliable
            $diff = $akhir->diff($awal);
            $totalHari = $diff->days;
            
            // DEBUG: Log perhitungan durasi
            \Log::info('JABATAN DURASI DEBUG', [
                'total_hari' => $totalHari,
                'diff_object' => [
                    'years' => $diff->y,
                    'months' => $diff->m,
                    'days' => $diff->d,
                    'total_days' => $diff->days
                ],
                'min_required' => 365,
                'max_allowed' => 1460,
                'is_valid_duration' => $totalHari >= 365 && $totalHari <= 1460
            ]);
            
            // Validasi durasi: minimal 1 tahun (365 hari)
            if ($totalHari < 365) {
                return response()->json([
                    'success' => false,
                    'message' => 'Durasi jabatan minimal 1 tahun',
                    'debug' => [
                        'total_hari' => $totalHari,
                        'hari_yang_dibutuhkan' => 365,
                        'kekurangan_hari' => 365 - $totalHari,
                        'awal' => $awal->toDateString(),
                        'akhir' => $akhir->toDateString()
                    ]
                ], 422);
            }
            
            // Validasi durasi: maksimal 4 tahun (1460 hari = 365 * 4)
            if ($totalHari > 1460) {
                return response()->json([
                    'success' => false,
                    'message' => 'Durasi jabatan maksimal 4 tahun',
                    'debug' => [
                        'total_hari' => $totalHari,
                        'hari_yang_diizinkan' => 1460,
                        'kelebihan_hari' => $totalHari - 1460,
                        'awal' => $awal->toDateString(),
                        'akhir' => $akhir->toDateString()
                    ]
                ], 422);
            }
            
            // Hitung durasi untuk response
            $durasiTahun = $diff->y;
            $durasiBulan = $diff->m;
            $sisaHari = $diff->d;
            
            // Validasi: tidak boleh tanggal di masa depan terlalu jauh (maks 5 tahun ke depan)
            $maxTahun = Carbon::now()->addYears(5);
            if ($akhir->greaterThan($maxTahun)) {
                return response()->json([
                    'success' => false,
                    'message' => 'Tanggal akhir tidak boleh lebih dari 5 tahun ke depan',
                    'debug' => [
                        'akhir' => $akhir->toDateString(),
                        'batas_maksimal' => $maxTahun->toDateString()
                    ]
                ], 422);
            }

            // Cek apakah ada jabatan aktif dengan nama yang sama (tumpang tindih periode)
            $existingJabatan = Jabatan::where('Jabatan', $validated['Jabatan'])
                ->where(function($query) use ($awal, $akhir) {
                    // Cek tumpang tindih periode
                    $query->whereBetween('Awal_jabatan', [$awal, $akhir])
                          ->orWhereBetween('Akhir_jabatan', [$awal, $akhir])
                          ->orWhere(function($q) use ($awal, $akhir) {
                              $q->where('Awal_jabatan', '<=', $awal)
                                ->where('Akhir_jabatan', '>=', $akhir);
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

            return response()->json([
                'success' => true,
                'message' => 'Jabatan berhasil dibuat',
                'data' => $jabatan,
                'durasi' => [
                    'tahun' => $durasiTahun,
                    'bulan' => $durasiBulan,
                    'hari' => $sisaHari,
                    'total_hari' => $totalHari
                ]
            ], 201);
            
        } catch (\Exception $e) {
            \Log::error('JABATAN CREATE ERROR', [
                'error' => $e->getMessage(),
                'trace' => $e->getTraceAsString(),
                'input' => $validated
            ]);
            
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

            // Hitung durasi untuk response
            $awal = Carbon::parse($jabatan->Awal_jabatan);
            $akhir = Carbon::parse($jabatan->Akhir_jabatan);
            
            // Gunakan diff() untuk hasil yang akurat
            $diff = $akhir->diff($awal);
            $durasiTahun = $diff->y;
            $durasiBulan = $diff->m;
            $sisaHari = $diff->d;
            $totalHari = $diff->days;
            
            $jabatanData = $jabatan->toArray();
            $jabatanData['durasi'] = [
                'tahun' => $durasiTahun,
                'bulan' => $durasiBulan,
                'hari' => $sisaHari,
                'total_hari' => $totalHari
            ];
            $jabatanData['status'] = $this->getStatusJabatan($awal, $akhir);

            return response()->json([
                'success' => true,
                'data' => $jabatanData
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

            // Validasi untuk update
            $validated = $request->validate([
                'Jabatan' => [
                    'sometimes',
                    'required',
                    'string',
                    'min:3',
                    'max:50',
                    'regex:/^[a-zA-Z\s]+$/'
                ],
                'Awal_jabatan' => [
                    'sometimes',
                    'required',
                    'date',
                    'date_format:Y-m-d'
                ],
                'Akhir_jabatan' => [
                    'sometimes',
                    'required',
                    'date',
                    'date_format:Y-m-d'
                ]
            ], [
                'Jabatan.min' => 'Nama jabatan minimal 3 karakter',
                'Jabatan.max' => 'Nama jabatan maksimal 50 karakter',
                'Jabatan.regex' => 'Nama jabatan hanya boleh mengandung huruf dan spasi'
            ]);

            // Jika ada update tanggal, validasi durasi
            if ($request->has('Awal_jabatan') || $request->has('Akhir_jabatan')) {
                $awal = $request->has('Awal_jabatan') 
                    ? Carbon::createFromFormat('Y-m-d', $validated['Awal_jabatan'] ?? $request->Awal_jabatan)->startOfDay()
                    : Carbon::parse($jabatan->Awal_jabatan)->startOfDay();
                    
                $akhir = $request->has('Akhir_jabatan')
                    ? Carbon::createFromFormat('Y-m-d', $validated['Akhir_jabatan'] ?? $request->Akhir_jabatan)->endOfDay()
                    : Carbon::parse($jabatan->Akhir_jabatan)->endOfDay();
                
                // Validasi: Awal harus <= Akhir
                if ($awal->greaterThan($akhir)) {
                    return response()->json([
                        'success' => false,
                        'message' => 'Tanggal awal harus sebelum atau sama dengan tanggal akhir'
                    ], 422);
                }
                
                // Hitung durasi
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

            // Business rule: cek tumpang tindih dengan jabatan lain
            if ($request->has('Jabatan') || $request->has('Awal_jabatan') || $request->has('Akhir_jabatan')) {
                $nama = $request->has('Jabatan') 
                    ? ($validated['Jabatan'] ?? $request->Jabatan) 
                    : $jabatan->Jabatan;
                    
                $awal = $request->has('Awal_jabatan') 
                    ? Carbon::createFromFormat('Y-m-d', $validated['Awal_jabatan'] ?? $request->Awal_jabatan)->startOfDay()
                    : Carbon::parse($jabatan->Awal_jabatan)->startOfDay();
                    
                $akhir = $request->has('Akhir_jabatan')
                    ? Carbon::createFromFormat('Y-m-d', $validated['Akhir_jabatan'] ?? $request->Akhir_jabatan)->endOfDay()
                    : Carbon::parse($jabatan->Akhir_jabatan)->endOfDay();

                $existingJabatan = Jabatan::where('Jabatan', $nama)
                    ->where('Id_jabatan', '!=', $id)
                    ->where(function($query) use ($awal, $akhir) {
                        $query->whereBetween('Awal_jabatan', [$awal, $akhir])
                              ->orWhereBetween('Akhir_jabatan', [$awal, $akhir])
                              ->orWhere(function($q) use ($awal, $akhir) {
                                  $q->where('Awal_jabatan', '<=', $awal)
                                    ->where('Akhir_jabatan', '>=', $akhir);
                              });
                    })
                    ->first();

                if ($existingJabatan) {
                    return response()->json([
                        'success' => false,
                        'message' => 'Jabatan dengan nama ini sudah ada dalam periode yang tumpang tindih'
                    ], 409);
                }
            }

            $jabatan->update($validated);
            
            // Hitung durasi setelah update
            $awal = Carbon::parse($jabatan->Awal_jabatan);
            $akhir = Carbon::parse($jabatan->Akhir_jabatan);
            $diff = $akhir->diff($awal);

            return response()->json([
                'success' => true,
                'message' => 'Jabatan berhasil diperbarui',
                'data' => $jabatan,
                'durasi' => [
                    'tahun' => $diff->y,
                    'bulan' => $diff->m,
                    'hari' => $diff->d,
                    'total_hari' => $diff->days
                ]
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

            // Cek apakah jabatan memiliki profil terkait
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

    // Helper function: menentukan status jabatan
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