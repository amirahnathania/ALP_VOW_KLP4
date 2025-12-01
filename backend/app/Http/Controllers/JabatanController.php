<?php

namespace App\Http\Controllers;

use App\Models\Jabatan;
use Illuminate\Http\Request;

class JabatanController extends Controller
{
    public function index()
    {
        $jabatan = Jabatan::all();
        return response()->json([
            'success' => true,
            'data' => $jabatan
        ]);
    }

    public function store(Request $request)
    {
        $request->validate([
            'Jabatan' => 'required|string|max:255',
            'Awal_jabatan' => 'required|date',
            'Akhir_jabatan' => 'required|date|after:Awal_jabatan',
        ]);

        $jabatan = Jabatan::create($request->all());

        return response()->json([
            'success' => true,
            'message' => 'Jabatan created successfully',
            'data' => $jabatan
        ], 201);
    }

    public function show($id)
    {
        $jabatan = Jabatan::find($id);
        
        if (!$jabatan) {
            return response()->json([
                'success' => false,
                'message' => 'Jabatan not found'
            ], 404);
        }

        return response()->json([
            'success' => true,
            'data' => $jabatan
        ]);
    }

    public function update(Request $request, $id)
    {
        $jabatan = Jabatan::find($id);
        
        if (!$jabatan) {
            return response()->json([
                'success' => false,
                'message' => 'Jabatan not found'
            ], 404);
        }

        $request->validate([
            'Jabatan' => 'sometimes|string|max:255',
            'Awal_jabatan' => 'sometimes|date',
            'Akhir_jabatan' => 'sometimes|date|after:Awal_jabatan',
        ]);

        $jabatan->update($request->all());

        return response()->json([
            'success' => true,
            'message' => 'Jabatan updated successfully',
            'data' => $jabatan
        ]);
    }

    public function destroy($id)
    {
        $jabatan = Jabatan::find($id);
        
        if (!$jabatan) {
            return response()->json([
                'success' => false,
                'message' => 'Jabatan not found'
            ], 404);
        }

        $jabatan->delete();

        return response()->json([
            'success' => true,
            'message' => 'Jabatan deleted successfully'
        ]);
    }
}