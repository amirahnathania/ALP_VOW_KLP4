<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Models\BuktiKegiatan;
use App\Http\Requests\StoreBuktiKegiatanRequest;
use App\Http\Resources\BuktiKegiatanResource;
use Illuminate\Validation\Rule;
use Illuminate\Support\Str;

class BuktiKegiatanController extends Controller
{
    // GET /api/bukti-kegiatan
    public function index()
    {
        $buktiKegiatans = BuktiKegiatan::with([
            'profil:id,id_user,id_jabatan',
            'profil.user:id,nama_pengguna',
            'profil.jabatan:id,jabatan',
            'kegiatan:id,jenis_kegiatan'
        ])->get()
            ->map(function ($buktiKegiatan) {
                // Add extra fields for Resource
                $buktiKegiatan->nama_pengguna = $buktiKegiatan->profil?->user?->nama_pengguna;
                $buktiKegiatan->jabatan = $buktiKegiatan->profil?->jabatan?->jabatan;
                $buktiKegiatan->jenis_kegiatan = $buktiKegiatan->kegiatan?->jenis_kegiatan;
                return $buktiKegiatan;
            });

        return response()->json([
            'success' => true,
            'message' => 'Daftar semua bukti kegiatan',
            'data' => BuktiKegiatanResource::collection($buktiKegiatans)
        ]);
    }

    // POST /api/bukti-kegiatan
    public function store(StoreBuktiKegiatanRequest $request)
    {
        $validated = $request->validated();


        $file = $request->file('foto');
        $extension = $file->getClientOriginalExtension();
        $mimeType = $file->getClientMimeType();

        // Generate unique filename
        $filename = 'bukti_' . $validated['id_kegiatan'] . '_' . $validated['id_profil'] . '_' . time() . '_' . Str::random(8) . '.' . $extension;

        // Move file to public/images
        $file->move(public_path('images'), $filename);

        $buktiKegiatan = BuktiKegiatan::create([
            'id_kegiatan' => $validated['id_kegiatan'],
            'id_profil' => $validated['id_profil'],
            'nama_foto' => $filename,
            'tipe_foto' => $mimeType,
        ]);

        $buktiKegiatan->load(['kegiatan', 'profil.user', 'profil.jabatan']);

        return response()->json([
            'success' => true,
            'message' => 'Bukti Kegiatan berhasil ditambah',
            'data' => new BuktiKegiatanResource($buktiKegiatan)
        ], 201);
    }

    // GET /api/bukti-kegiatan/{id}
    public function show($id)
    {
        $buktiKegiatan = BuktiKegiatan::with([
            'profil:id,id_user,id_jabatan',
            'profil.user:id,nama_pengguna',
            'profil.jabatan:id,jabatan',
            'kegiatan:id,jenis_kegiatan'
        ])->find($id);

        if (!$buktiKegiatan) {
            return response()->json([
                'success' => false,
                'message' => 'Bukti Kegiatan tidak ditemukan'
            ], 404);
        }

        // Add extra fields for Resource
        $buktiKegiatan->nama_pengguna = $buktiKegiatan->profil?->user?->nama_pengguna;
        $buktiKegiatan->jabatan = $buktiKegiatan->profil?->jabatan?->jabatan;
        $buktiKegiatan->jenis_kegiatan = $buktiKegiatan->kegiatan?->jenis_kegiatan;

        return response()->json([
            'success' => true,
            'data' => new BuktiKegiatanResource($buktiKegiatan)
        ]);
    }

    // GET /api/bukti-kegiatan/{id}/image
    public function getImage($id)
    {
        $buktiKegiatan = BuktiKegiatan::find($id);

        if (!$buktiKegiatan) {
            return response()->json([
                'success' => false,
                'message' => 'Bukti Kegiatan tidak ditemukan'
            ], 404);
        }

        $imagePath = public_path('images/' . $buktiKegiatan->nama_foto);

        if (!file_exists($imagePath)) {
            return response()->json([
                'success' => false,
                'message' => 'File gambar tidak ditemukan'
            ], 404);
        }

        return response()->file($imagePath, [
            'Content-Type' => $buktiKegiatan->tipe_foto ?? 'image/jpeg'
        ]);
    }

    // PUT/PATCH /api/bukti-kegiatan/{id}
    public function update(Request $request, $id)
    {
        $buktiKegiatan = BuktiKegiatan::find($id);

        if (!$buktiKegiatan) {
            return response()->json([
                'success' => false,
                'message' => 'Bukti Kegiatan tidak ditemukan'
            ], 404);
        }

        $request->validate([
            'id_kegiatan' => [
                'sometimes',
                'required',
                Rule::exists('kegiatan', 'id')
            ],
            'id_profil' => [
                'sometimes',
                'required',
                Rule::exists('profil', 'id')
            ],
            'foto' => 'sometimes|required|image|mimes:png,jpg,jpeg,svg,gif,webp|max:5120'
        ], [
            'foto.image' => 'File harus berupa gambar',
            'foto.mimes' => 'Format gambar harus: png, jpg, jpeg, svg, gif, atau webp',
            'foto.max' => 'Ukuran gambar tidak boleh lebih dari 5MB',
        ]);

        $data = [];

        if ($request->has('id_kegiatan')) {
            $data['id_kegiatan'] = $request->input('id_kegiatan');
        }
        if ($request->has('id_profil')) {
            $data['id_profil'] = $request->input('id_profil');
        }

        // Handle file upload if provided
        if ($request->hasFile('foto')) {
            // Delete old file
            $oldImagePath = public_path('images/' . $buktiKegiatan->nama_foto);
            if (file_exists($oldImagePath)) {
                unlink($oldImagePath);
            }

            $file = $request->file('foto');
            $extension = $file->getClientOriginalExtension();
            $mimeType = $file->getClientMimeType();

            $idKegiatan = $data['id_kegiatan'] ?? $buktiKegiatan->id_kegiatan;
            $idProfil = $data['id_profil'] ?? $buktiKegiatan->id_profil;

            $filename = 'bukti_' . $idKegiatan . '_' . $idProfil . '_' . time() . '_' . Str::random(8) . '.' . $extension;

            $file->move(public_path('images'), $filename);

            $data['nama_foto'] = $filename;
            $data['tipe_foto'] = $mimeType;
        }

        $buktiKegiatan->update($data);
        $buktiKegiatan->load(['kegiatan', 'profil.user', 'profil.jabatan']);

        return response()->json([
            'success' => true,
            'message' => 'Bukti Kegiatan berhasil diperbarui',
            'data' => new BuktiKegiatanResource($buktiKegiatan)
        ]);
    }

    // DELETE /api/bukti-kegiatan/{id}
    public function destroy($id)
    {
        $buktiKegiatan = BuktiKegiatan::find($id);

        if (!$buktiKegiatan) {
            return response()->json([
                'success' => false,
                'message' => 'Bukti Kegiatan tidak ditemukan'
            ], 404);
        }

        // Delete the image file
        $imagePath = public_path('images/' . $buktiKegiatan->nama_foto);
        if (file_exists($imagePath)) {
            unlink($imagePath);
        }

        $buktiKegiatan->delete();

        return response()->json([
            'success' => true,
            'message' => 'Bukti Kegiatan berhasil dihapus'
        ]);
    }
}
