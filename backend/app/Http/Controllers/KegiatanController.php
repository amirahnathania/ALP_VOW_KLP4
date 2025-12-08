<?php

namespace App\Http\Controllers;

use App\Models\Kegiatan;
use Illuminate\Http\Request;

class KegiatanController extends Controller
{
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
        $Validated = $request->validate([
            'Jenis_Kegiatan' => 'required|string|max:255',
            'Id_profil' => 'required|exists:profil,Id_Profil',
            'Tanggal' => 'required|date',
            'Waktu' => 'required|date_format:H:i:s',
            'Jenis_Pestisida' => 'nullable|string|max:255',
            'Target_Penanaman' => 'required|integer',
            'Keterangan' => 'nullable|string',
        ]);

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
    public function show(Kegiatan $kegiatan)
    {
        $kegiatan->load('profil');
        return response()->json([
            'success' => true,
            'data' => $kegiatan
        ]);
    }

    /**
     * Update the specified resource in storage.
     */
    public function update(Request $request, Kegiatan $kegiatan)
    {
        $Validated = $request->validate([
            'Jenis_Kegiatan' => 'sometimes|required|string|max:255',
            'Id_profil' => 'sometimes|required|exists:profil,Id_Profil',
            'Tanggal' => 'sometimes|required|date',
            'Waktu' => 'sometimes|required|date_format:H:i:s',
            'Jenis_Pestisida' => 'nullable|string|max:255',
            'Target_Penanaman' => 'sometimes|required|integer',
            'Keterangan' => 'nullable|string',
        ]);

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
}
