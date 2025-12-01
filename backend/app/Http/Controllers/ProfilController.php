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