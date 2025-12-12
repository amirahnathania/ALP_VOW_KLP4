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
     * Menyimpan file gambar sebagai BLOB di database
     */
    public function store(Request $request)
    {
        $isFile = $request->hasFile('Bukti_Foto');

        $validationRules = [
            'Id_Kegiatan' => [
                'required',
                Rule::exists('kegiatans', 'Id_Kegiatan')
            ],
            'Id_User' => [
                'required',
                Rule::exists('users', 'Id_User'),
                Rule::unique('bukti_kegiatans', 'Id_User')
            ],
        ];

        // Bukti_Foto harus berupa file gambar
        $validationRules['Bukti_Foto'] = 'required|image|mimes:jpeg,jpg,png,gif,svg|max:5120';

        $request->validate($validationRules, [
            'Id_User.unique' => 'User ini sudah pernah mengirim bukti kegiatan. Satu user hanya boleh mengirim 1 bukti.',
            'Bukti_Foto.required' => 'Anda harus mengirim file gambar',
            'Bukti_Foto.image' => 'Anda hanya dapat mengirim gambar',
            'Bukti_Foto.mimes' => 'Anda hanya dapat mengirim gambar',
            'Bukti_Foto.max' => 'Ukuran gambar tidak boleh lebih dari 5MB',
        ]);

        if (!$isFile) {
            return response()->json([
                'success' => false,
                'message' => 'Anda harus mengirim file gambar'
            ], 422);
        }

        // Baca file sebagai binary data (BLOB)
        $file = $request->file('Bukti_Foto');
        $fileBinary = file_get_contents($file->getRealPath());
        $mimeType = $file->getClientMimeType();

        $data = [
            'Id_Kegiatan' => $request->input('Id_Kegiatan'),
            'Id_User' => $request->input('Id_User'),
            'Bukti_Foto' => $fileBinary,
            'mime_type' => $mimeType
        ];

        $buktiKegiatan = BuktiKegiatan::create($data);
        
        // Return tanpa BLOB (karena BLOB tidak perlu di-return dalam JSON)
        $buktiKegiatan->load(['kegiatan', 'user']);
        
        // Clone model dan hapus Bukti_Foto untuk response
        $response = $buktiKegiatan->toArray();
        unset($response['Bukti_Foto']);
        
        return response()->json([
            'success' => true,
            'message' => 'Bukti Kegiatan berhasil ditambah',
            'data' => array_merge($response, ['mime_type' => $mimeType])
        ], 201);
    }

    /**
     * Display the specified resource.
     */
    public function show(BuktiKegiatan $buktiKegiatan)
    {
        $buktiKegiatan->load(['kegiatan', 'user']);
        
        // Clone dan hapus BLOB dari response JSON
        $data = $buktiKegiatan->toArray();
        unset($data['Bukti_Foto']);
        
        return response()->json([
            'success' => true,
            'data' => $data
        ]);
    }

    /**
     * Get image dari BLOB dan return sebagai image response
     */
    public function getImage($id)
    {
        $buktiKegiatan = BuktiKegiatan::find($id);
        
        if (!$buktiKegiatan || !$buktiKegiatan->Bukti_Foto) {
            return response()->json([
                'success' => false,
                'message' => 'Bukti Kegiatan atau gambar tidak ditemukan'
            ], 404);
        }

        return response($buktiKegiatan->Bukti_Foto, 200)
            ->header('Content-Type', $buktiKegiatan->mime_type ?? 'image/jpeg')
            ->header('Content-Disposition', 'inline; filename="bukti-kegiatan-' . $id . '.jpg"');
    }

    /**
     * Update the specified resource in storage.
     */
    public function update(Request $request, BuktiKegiatan $buktiKegiatan)
    {
        $isFile = $request->hasFile('Bukti_Foto');

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

        // If Bukti_Foto is provided, it must be a file image
        if ($request->has('Bukti_Foto')) {
            $validationRules['Bukti_Foto'] = 'required|image|mimes:jpeg,jpg,png,gif,svg|max:5120';
        }

        $request->validate($validationRules, [
            'Bukti_Foto.required' => 'Anda harus mengirim file gambar',
            'Bukti_Foto.image' => 'Anda hanya dapat mengirim gambar',
            'Bukti_Foto.mimes' => 'Anda hanya dapat mengirim gambar',
            'Bukti_Foto.max' => 'Ukuran gambar tidak boleh lebih dari 5MB',
        ]);

        $data = [];

        if ($request->has('Id_Kegiatan')) {
            $data['Id_Kegiatan'] = $request->input('Id_Kegiatan');
        }
        if ($request->has('Id_User')) {
            $data['Id_User'] = $request->input('Id_User');
        }

        // Handle file upload if provided - simpan sebagai BLOB
        if ($isFile) {
            $file = $request->file('Bukti_Foto');
            $fileBinary = file_get_contents($file->getRealPath());
            $mimeType = $file->getClientMimeType();
            
            $data['Bukti_Foto'] = $fileBinary;
            $data['mime_type'] = $mimeType;
        }

        $buktiKegiatan->update($data);
        $buktiKegiatan->load(['kegiatan', 'user']);

        // Return tanpa BLOB
        $response = $buktiKegiatan->toArray();
        unset($response['Bukti_Foto']);

        return response()->json([
            'success' => true,
            'message' => 'Bukti Kegiatan berhasil diperbarui',
            'data' => $response
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
