<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Models\BuktiKegiatan;
use Illuminate\Validation\Rule;
use Illuminate\Support\Facades\Storage;

class BuktiKegiatanController extends Controller
{
    /**
     * Display a listing of the resource.
     */
    public function index()
    {
        $buktiKegiatans = BuktiKegiatan::with(['kegiatan', 'user'])->get();
        return response()->json([
            'success' => true,
            'message' => 'Daftar semua bukti kegiatan',
            'data' => $buktiKegiatans
        ]);
    }

    /**
     * Store a newly created resource in storage.
     */
    public function store(Request $request)
    {
        // Check if Bukti_Foto is a file or string
        $isFile = $request->hasFile('Bukti_Foto');
        $isString = $request->has('Bukti_Foto') && is_string($request->input('Bukti_Foto'));

        $validationRules = [
            'Id_Kegiatan' => 'required|exists:kegiatans,Id_Kegiatan',
            'Id_User' => 'required|exists:users,Id_User|unique:bukti_kegiatans,Id_User',
        ];

        // Only validate as image if it's a file upload
        if ($isFile) {
            $validationRules['Bukti_Foto'] = 'required|image|mimes:jpeg,jpg,png,gif,svg|max:5120';
        } else {
            $validationRules['Bukti_Foto'] = 'required|string';
        }

        $request->validate($validationRules, [
            'Id_User.unique' => 'User ini sudah pernah mengirim bukti kegiatan. Satu user hanya boleh mengirim 1 bukti.',
        ]);

        // Handle file upload or string path
        $fotoPath = null;
        if ($isFile) {
            $file = $request->file('Bukti_Foto');
            $fotoPath = $file->store('bukti_kegiatans', 'public');
        } elseif ($isString) {
            $fotoPath = $request->input('Bukti_Foto');
        }

        if (!$fotoPath) {
            return response()->json([
                'success' => false,
                'message' => 'Bukti_Foto is required (file or string path)'
            ], 422);
        }

        $data = [
            'Id_Kegiatan' => $request->input('Id_Kegiatan'),
            'Id_User' => $request->input('Id_User'),
            'Bukti_Foto' => $fotoPath
        ];

        $buktiKegiatan = BuktiKegiatan::create($data);
        $buktiKegiatan->load(['kegiatan', 'user']);
        return response()->json([
            'success' => true,
            'message' => 'Bukti Kegiatan berhasil ditambah',
            'data' => $buktiKegiatan
        ], 201);
    }

    /**
     * Display the specified resource.
     */
    public function show(BuktiKegiatan $buktiKegiatan)
    {
        $buktiKegiatan->load(['kegiatan', 'user']);
        return response()->json([
            'success' => true,
            'data' => $buktiKegiatan
        ]);
    }

    /**
     * Update the specified resource in storage.
     */
    public function update(Request $request, BuktiKegiatan $buktiKegiatan)
    {
        // Check if Bukti_Foto is a file or string
        $isFile = $request->hasFile('Bukti_Foto');
        $isString = $request->has('Bukti_Foto') && is_string($request->input('Bukti_Foto'));

        $validationRules = [
            'Id_Kegiatan' => [
                'sometimes',
                'required',
                Rule::exists('kegiatans', 'Id_Kegiatan')
            ],
            'Id_User' => [
                'sometimes',
                'required',
                Rule::exists('users', 'Id_User')
            ],
        ];

        // Only validate as image if it's a file upload
        if ($isFile) {
            $validationRules['Bukti_Foto'] = 'sometimes|image|mimes:jpeg,jpg,png,gif,svg|max:5120';
        } elseif ($isString) {
            $validationRules['Bukti_Foto'] = 'sometimes|string';
        }

        $request->validate($validationRules);

        $data = [];

        if ($request->has('Id_Kegiatan')) {
            $data['Id_Kegiatan'] = $request->input('Id_Kegiatan');
        }
        if ($request->has('Id_User')) {
            $data['Id_User'] = $request->input('Id_User');
        }

        // Handle file upload if provided
        if ($isFile) {
            // Delete old file if exists
            if ($buktiKegiatan->Bukti_Foto) {
                Storage::disk('public')->delete($buktiKegiatan->Bukti_Foto);
            }
            $file = $request->file('Bukti_Foto');
            $data['Bukti_Foto'] = $file->store('bukti_kegiatans', 'public');
        } elseif ($isString) {
            // Allow string path for testing purposes
            if ($buktiKegiatan->Bukti_Foto) {
                Storage::disk('public')->delete($buktiKegiatan->Bukti_Foto);
            }
            $data['Bukti_Foto'] = $request->input('Bukti_Foto');
        }

        $buktiKegiatan->update($data);
        $buktiKegiatan->load(['kegiatan', 'user']);

        return response()->json([
            'success' => true,
            'message' => 'Bukti Kegiatan berhasil diperbarui',
            'data' => $buktiKegiatan
        ]);
    }

    /**
     * Remove the specified resource from storage.
     */
    public function destroy(string $id)
    {
        $buktiKegiatan = BuktiKegiatan::find($id);
        if (!$buktiKegiatan) {
            return response()->json([
                'success' => false,
                'message' => 'Bukti Kegiatan tidak ditemukan'
            ], 404);
        }

        $buktiKegiatan->delete();

        return response()->json([
            'success' => true,
            'message' => 'Bukti Kegiatan berhasil dihapus'
        ]);
    }
}
