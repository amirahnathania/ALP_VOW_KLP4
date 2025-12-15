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
            $validator = Validator::make($request->all(), [
                'id_user' => [
                    'required',
                    'integer',
                    'exists:users,id',
                    Rule::unique('profil', 'id_user')
                ],
                'id_jabatan' => [
                    'required',
                    'integer',
                    'exists:jabatan,id'
                ]
            ], [
                'id_user.required' => 'ID User wajib diisi',
                'id_user.integer' => 'ID User harus berupa angka',
                'id_user.exists' => 'User tidak ditemukan',
                'id_user.unique' => 'User sudah memiliki profil',

                'id_jabatan.required' => 'ID Jabatan wajib diisi',
                'id_jabatan.integer' => 'ID Jabatan harus berupa angka',
                'id_jabatan.exists' => 'Jabatan tidak ditemukan'
            ]);

            if ($validator->fails()) {
                return response()->json([
                    'success' => false,
                    'message' => 'Validasi gagal',
                    'errors' => $validator->errors()
                ], 422);
            }

            $validated = $validator->validated();

            $jabatan = Jabatan::find($validated['id_jabatan']);

            if ($jabatan->akhir_jabatan) {
                $today = date('Y-m-d');
                if ($jabatan->akhir_jabatan < $today) {
                    return response()->json([
                        'success' => false,
                        'message' => 'Jabatan sudah tidak aktif',
                        'data' => [
                            'jabatan' => $jabatan->jabatan,
                            'akhir_jabatan' => $jabatan->akhir_jabatan
                        ]
                    ], 400);
                }
            }

            $existingProfil = Profil::where('id_jabatan', $validated['id_jabatan'])
                ->whereHas('jabatan', function ($query) {
                    $query->where(function ($q) {
                        $q->where('akhir_jabatan', '>=', now()->format('Y-m-d'))
                            ->orWhereNull('akhir_jabatan');
                    });
                })
                ->first();

            if ($existingProfil) {
                return response()->json([
                    'success' => false,
                    'message' => 'Jabatan ini sudah diisi oleh user lain',
                    'data' => [
                        'jabatan' => $jabatan->jabatan,
                        'user_yang_sudah_ada' => $existingProfil->user->nama_pengguna ?? 'Unknown'
                    ]
                ], 409);
            }

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

            $validator = Validator::make($request->all(), [
                'id_user' => [
                    'sometimes',
                    'required',
                    'integer',
                    'exists:users,id',
                    Rule::unique('profil', 'id_user')->ignore($id)
                ],
                'id_jabatan' => [
                    'sometimes',
                    'required',
                    'integer',
                    'exists:jabatan,id'
                ]
            ]);

            if ($validator->fails()) {
                return response()->json([
                    'success' => false,
                    'message' => 'Validasi gagal',
                    'errors' => $validator->errors()
                ], 422);
            }

            $validated = $validator->validated();

            if ($request->has('id_jabatan') && $request->id_jabatan != $profil->id_jabatan) {
                $jabatan = Jabatan::find($validated['id_jabatan']);

                if ($jabatan->akhir_jabatan) {
                    $today = date('Y-m-d');
                    if ($jabatan->akhir_jabatan < $today) {
                        return response()->json([
                            'success' => false,
                            'message' => 'Jabatan sudah tidak aktif'
                        ], 400);
                    }
                }

                $existingProfil = Profil::where('id_jabatan', $validated['id_jabatan'])
                    ->where('id', '!=', $id)
                    ->whereHas('jabatan', function ($query) {
                        $query->where(function ($q) {
                            $q->where('akhir_jabatan', '>=', now()->format('Y-m-d'))
                                ->orWhereNull('akhir_jabatan');
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
