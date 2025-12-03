<?php

namespace App\Http\Controllers;

use App\Models\Profil;
use Illuminate\Http\Request;

class ProfilController extends Controller
{
    public function index()
    {
        $profil = Profil::with(['user', 'jabatan'])->get();
        return response()->json([
            'success' => true,
            'data' => $profil
        ]);
    }

    public function store(Request $request)
    {
        $request->validate([
            'Id_User' => 'required|exists:users,Id_User',
            'Id_jabatan' => 'required|exists:jabatan,Id_jabatan',
        ]);

        // Cek apakah user sudah punya profil
        $existingProfil = Profil::where('Id_User', $request->Id_User)->first();
        
        if ($existingProfil) {
            return response()->json([
                'success' => false,
                'message' => 'User already has a profile'
            ], 400);
        }

        $profil = Profil::create($request->all());
        $profil->load(['user', 'jabatan']);

        return response()->json([
            'success' => true,
            'message' => 'Profil created successfully',
            'data' => $profil
        ], 201);
    }

    public function show($id)
    {
        $profil = Profil::with(['user', 'jabatan'])->find($id);
        
        if (!$profil) {
            return response()->json([
                'success' => false,
                'message' => 'Profil not found'
            ], 404);
        }

        return response()->json([
            'success' => true,
            'data' => $profil
        ]);
    }

    public function showByUserId($userId)
    {
        $profil = Profil::with(['user', 'jabatan'])
                        ->where('Id_User', $userId)
                        ->first();
        
        if (!$profil) {
            return response()->json([
                'success' => false,
                'message' => 'Profil tidak ditemukan untuk user ini'
            ], 404);
        }

        // 1. Jabatan text dari role
        $jabatanText = 'Anggota';
        if ($profil->user->role == 'ketua') {
            $jabatanText = 'Ketua Komunitas';
        } elseif ($profil->user->role == 'gapoktan') {
            $jabatanText = 'Anggota Gapoktan';
        }
        
        // 2. PERIODE FIX SESUAI PERMINTAAN
        $tahunMulai = 2024; // FIX untuk semua
        
        if ($profil->user->role == 'ketua') {
            $tahunAkhir = 2025; // Ketua: 2024-2025 (2 tahun)
        } elseif ($profil->user->role == 'gapoktan') {
            $tahunAkhir = 2028; // Gapoktan: 2024-2028 (5 tahun)
        } else {
            $tahunAkhir = 2024; // default
        }

        return response()->json([
            'success' => true,
            'data' => [
                'user' => [
                    'Id_User' => $profil->user->Id_User,
                    'Nama_Pengguna' => $profil->user->Nama_Pengguna,
                    'Email' => $profil->user->Email,
                    'role' => $profil->user->role,
                ],
                'jabatan_text' => $jabatanText,
                'awal_masa_jabatan' => $tahunMulai,
                'akhir_masa_jabatan' => $tahunAkhir,
                'periode' => ($tahunAkhir - $tahunMulai + 1) . ' tahun', // hitung otomatis
                'profil_id' => $profil->Id_Profil,
            ]
        ]);
    }

    public function update(Request $request, $id)
    {
        $profil = Profil::find($id);
        
        if (!$profil) {
            return response()->json([
                'success' => false,
                'message' => 'Profil not found'
            ], 404);
        }

        $request->validate([
            'Id_User' => 'sometimes|required|exists:users,Id_User',
            'Id_jabatan' => 'sometimes|required|exists:jabatan,Id_jabatan',
        ]);

        $profil->update($request->all());
        $profil->load(['user', 'jabatan']);

        return response()->json([
            'success' => true,
            'message' => 'Profil updated successfully',
            'data' => $profil
        ]);
    }

    public function destroy($id)
    {
        $profil = Profil::find($id);
        
        if (!$profil) {
            return response()->json([
                'success' => false,
                'message' => 'Profil not found'
            ], 404);
        }

        $profil->delete();

        return response()->json([
            'success' => true,
            'message' => 'Profil deleted successfully'
        ]);
    }
}