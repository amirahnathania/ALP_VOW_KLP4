<?php

namespace App\Http\Controllers;

use App\Models\Profil;
use App\Models\User;
use App\Models\Jabatan;
use Illuminate\Http\Request;
use Illuminate\Validation\Rule;
use Illuminate\Support\Facades\Validator;

class ProfilController extends Controller
{
    // GET /api/profil
    public function index()
    {
        try {
            $profil = Profil::with(['user', 'jabatan'])->get();
            return response()->json([
                'success' => true,
                'data' => $profil,
                'count' => $profil->count()
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Gagal mengambil data profil',
                'error' => $e->getMessage()
            ], 500);
        }
    }

    // POST /api/profil
    public function store(Request $request)
    {
        try {
            // Validasi data input
            $validator = Validator::make($request->all(), [
                'Id_User' => [
                    'required',
                    'integer',
                    'exists:users,Id_User',
                    Rule::unique('profil', 'Id_User')->whereNull('deleted_at')
                ],
                'Id_jabatan' => [
                    'required',
                    'string',
                    'exists:jabatan,Id_jabatan'
                ]
            ], [
                'Id_User.required' => 'ID User wajib diisi',
                'Id_User.integer' => 'ID User harus berupa angka',
                'Id_User.exists' => 'User tidak ditemukan',
                'Id_User.unique' => 'User sudah memiliki profil',
                
                'Id_jabatan.required' => 'ID Jabatan wajib diisi',
                'Id_jabatan.string' => 'ID Jabatan harus berupa teks',
                'Id_jabatan.exists' => 'Jabatan tidak ditemukan'
            ]);

            if ($validator->fails()) {
                return response()->json([
                    'success' => false,
                    'message' => 'Validasi gagal',
                    'errors' => $validator->errors()
                ], 422);
            }

            $validated = $validator->validated();

            // Cek apakah jabatan masih aktif (business rule)
            $jabatan = Jabatan::where('Id_jabatan', $validated['Id_jabatan'])->first();
            
            if (isset($jabatan->Akhir_jabatan)) {
                $today = date('Y-m-d');
                if ($jabatan->Akhir_jabatan < $today) {
                    return response()->json([
                        'success' => false,
                        'message' => 'Jabatan sudah tidak aktif',
                        'data' => [
                            'jabatan' => $jabatan->Jabatan ?? $jabatan->nama_jabatan,
                            'akhir_jabatan' => $jabatan->Akhir_jabatan
                        ]
                    ], 400);
                }
            }

            // Business rule: cek apakah jabatan sudah penuh
            // Query yang lebih sederhana
            $existingProfil = Profil::where('Id_jabatan', $validated['Id_jabatan'])
                ->whereHas('jabatan', function($query) {
                    $query->where(function($q) {
                        $q->where('Akhir_jabatan', '>=', now()->format('Y-m-d'))
                          ->orWhereNull('Akhir_jabatan');
                    });
                })
                ->first();

            if ($existingProfil) {
                return response()->json([
                    'success' => false,
                    'message' => 'Jabatan ini sudah diisi oleh user lain',
                    'data' => [
                        'jabatan' => $jabatan->Jabatan ?? $jabatan->nama_jabatan,
                        'user_yang_sudah_ada' => $existingProfil->user->Nama_Pengguna ?? 'Unknown'
                    ]
                ], 409);
            }

            // Create profil
            $profil = Profil::create($validated);
            $profil->load(['user', 'jabatan']);

            return response()->json([
                'success' => true,
                'message' => 'Profil berhasil dibuat',
                'data' => $profil
            ], 201);
            
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Gagal membuat profil',
                'error' => $e->getMessage()
            ], 500);
        }
    }

    // GET /api/profil/{id}
    public function show($id)
    {
        try {
            // Validasi ID harus integer
            if (!is_numeric($id)) {
                return response()->json([
                    'success' => false,
                    'message' => 'ID harus berupa angka'
                ], 400);
            }

            $profil = Profil::with(['user', 'jabatan'])->find($id);
            
            if (!$profil) {
                return response()->json([
                    'success' => false,
                    'message' => 'Profil tidak ditemukan'
                ], 404);
            }

            return response()->json([
                'success' => true,
                'data' => $profil
            ]);
            
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Gagal mengambil data profil',
                'error' => $e->getMessage()
            ], 500);
        }
    }

    // PUT/PATCH /api/profil/{id}
    public function update(Request $request, $id)
    {
        try {
            // Validasi ID harus integer
            if (!is_numeric($id)) {
                return response()->json([
                    'success' => false,
                    'message' => 'ID harus berupa angka'
                ], 400);
            }

            $profil = Profil::find($id);
            
            if (!$profil) {
                return response()->json([
                    'success' => false,
                    'message' => 'Profil tidak ditemukan'
                ], 404);
            }

            // Validasi untuk update
            $validator = Validator::make($request->all(), [
                'Id_User' => [
                    'sometimes',
                    'required',
                    'integer',
                    'exists:users,Id_User',
                    Rule::unique('profil', 'Id_User')->ignore($id, 'Id_Profil')
                ],
                'Id_jabatan' => [
                    'sometimes',
                    'required',
                    'string',
                    'exists:jabatan,Id_jabatan'
                ]
            ], [
                'Id_User.integer' => 'ID User harus berupa angka',
                'Id_User.exists' => 'User tidak ditemukan',
                'Id_User.unique' => 'User sudah memiliki profil',
                
                'Id_jabatan.string' => 'ID Jabatan harus berupa teks',
                'Id_jabatan.exists' => 'Jabatan tidak ditemukan'
            ]);

            if ($validator->fails()) {
                return response()->json([
                    'success' => false,
                    'message' => 'Validasi gagal',
                    'errors' => $validator->errors()
                ], 422);
            }

            $validated = $validator->validated();

            // Jika ada update Id_jabatan, cek business rules
            if ($request->has('Id_jabatan') && $request->Id_jabatan != $profil->Id_jabatan) {
                $jabatan = Jabatan::where('Id_jabatan', $validated['Id_jabatan'])->first();
                
                // Cek apakah jabatan masih aktif
                if (isset($jabatan->Akhir_jabatan)) {
                    $today = date('Y-m-d');
                    if ($jabatan->Akhir_jabatan < $today) {
                        return response()->json([
                            'success' => false,
                            'message' => 'Jabatan sudah tidak aktif'
                        ], 400);
                    }
                }

                // Business rule: cek apakah jabatan sudah penuh
                $existingProfil = Profil::where('Id_jabatan', $validated['Id_jabatan'])
                    ->where('Id_Profil', '!=', $id)
                    ->whereHas('jabatan', function($query) {
                        $query->where(function($q) {
                            $q->where('Akhir_jabatan', '>=', now()->format('Y-m-d'))
                              ->orWhereNull('Akhir_jabatan');
                        });
                    })
                    ->first();

                if ($existingProfil) {
                    return response()->json([
                        'success' => false,
                        'message' => 'Jabatan ini sudah diisi oleh user lain'
                    ], 409);
                }
            }

            $profil->update($validated);
            $profil->load(['user', 'jabatan']);

            return response()->json([
                'success' => true,
                'message' => 'Profil berhasil diperbarui',
                'data' => $profil
            ]);
            
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Gagal mengupdate profil',
                'error' => $e->getMessage()
            ], 500);
        }
    }

    // DELETE /api/profil/{id}
    public function destroy($id)
    {
        try {
            // Validasi ID harus integer
            if (!is_numeric($id)) {
                return response()->json([
                    'success' => false,
                    'message' => 'ID harus berupa angka'
                ], 400);
            }

            $profil = Profil::find($id);
            
            if (!$profil) {
                return response()->json([
                    'success' => false,
                    'message' => 'Profil tidak ditemukan'
                ], 404);
            }

            // Business rule: cek jika jabatan penting
            $jabatan = $profil->jabatan;
            if ($jabatan) {
                $namaJabatan = strtolower($jabatan->Jabatan ?? $jabatan->nama_jabatan ?? '');
                if (str_contains($namaJabatan, 'direktur') || str_contains($namaJabatan, 'ketua')) {
                    return response()->json([
                        'success' => false,
                        'message' => 'Profil dengan jabatan penting tidak boleh dihapus'
                    ], 403);
                }
            }

            $profil->delete();

            return response()->json([
                'success' => true,
                'message' => 'Profil berhasil dihapus'
            ]);
            
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Gagal menghapus profil',
                'error' => $e->getMessage()
            ], 500);
        }
    }
}