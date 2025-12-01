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
        return response()->json(Kegiatan::all());
    }

    /**
     * Store a newly created resource in storage.
     */
    public function store(Request $request)
    {
        $Validated = $request->validate([
            'Nama_Kegiatan' => 'required|string|max:255',
            'Deskripsi' => 'required|string',
            'Tanggal' => 'required|date',
            'Waktu' => 'required',
            'Target_Penanaman' => 'required|integer',
        ]);

        $kegiatan = Kegiatan::create($Validated);
        return response()->json(['message' => 'Keigatan sudah ditamabah' , 'data' => $kegiatan], 201);
    }

    /**
     * Display the specified resource.
     */
    public function show(Kegiatan $kegiatan)
    {
        return response()->json($kegiatan);
    }

    /**
     * Update the specified resource in storage.
     */
    public function update(Request $request, Kegiatan $kegiatan)
    {
        $Validated = $request->validate([
            'Nama_Kegiatan' => 'sometimes|required|string|max:255',
            'Deskripsi' => 'sometimes|required|string',
            'Tanggal' => 'sometimes|required|date',
            'Waktu' => 'sometimes|required',
            'Target_Penanaman' => 'sometimes|required|integer',
        ]);

        $kegiatan->update($Validated);
        return response()->json(['message' => 'Kegiatan sudah diperbarui', 'data' => $kegiatan]);
    }

    /**
     * Remove the specified resource from storage.
     */
    public function destroy(string $id)
    {
        $kegiatan = Kegiatan::find($id);
        if (!$kegiatan) {
            return response()->json(['message' => 'Kegiatan tidak ditemukan'], 404);
        }

        $kegiatan->delete();
        return response()->json(['message' => 'Kegiatan sudah dihapus']);
    }
}
