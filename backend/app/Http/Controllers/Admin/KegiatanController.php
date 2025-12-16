<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\Kegiatan;
use App\Models\Profil;
use Illuminate\Http\Request;
use Carbon\Carbon;

class KegiatanController extends Controller
{
    /**
     * Display a listing of kegiatan
     */
    public function index(Request $request)
    {
        $query = Kegiatan::with(['profil.user', 'profil.jabatan', 'buktiKegiatan']);

        // Search
        if ($request->filled('search')) {
            $search = $request->search;
            $query->where(function ($q) use ($search) {
                $q->where('jenis_kegiatan', 'like', "%{$search}%")
                    ->orWhere('keterangan', 'like', "%{$search}%");
            });
        }

        // Filter by jenis kegiatan
        if ($request->filled('jenis')) {
            $query->where('jenis_kegiatan', $request->jenis);
        }

        // Filter by status
        if ($request->filled('status')) {
            $now = Carbon::now();
            if ($request->status === 'active') {
                $query->where('tanggal_selesai', '>=', $now);
            } elseif ($request->status === 'completed') {
                $query->where('tanggal_selesai', '<', $now);
            }
        }

        // Filter by date range
        if ($request->filled('date_from')) {
            $query->where('tanggal_mulai', '>=', $request->date_from);
        }
        if ($request->filled('date_to')) {
            $query->where('tanggal_selesai', '<=', $request->date_to);
        }

        // Sort
        $sortField = $request->get('sort', 'tanggal_mulai');
        $sortDirection = $request->get('direction', 'desc');
        $query->orderBy($sortField, $sortDirection);

        $kegiatans = $query->paginate(10)->withQueryString();
        $profils = Profil::with('user')->get();
        $jenisKegiatans = Kegiatan::distinct()->pluck('jenis_kegiatan');

        if ($request->ajax()) {
            return response()->json([
                'success' => true,
                'html' => view('admin.kegiatan._table', compact('kegiatans'))->render(),
                'pagination' => view('admin.partials._pagination', compact('kegiatans'))->render(),
            ]);
        }

        return view('admin.kegiatan.index', compact('kegiatans', 'profils', 'jenisKegiatans'));
    }

    /**
     * Show form for creating new kegiatan
     */
    public function create()
    {
        $profils = Profil::with('user')->get();
        return view('admin.kegiatan.create', compact('profils'));
    }

    /**
     * Store a newly created kegiatan
     */
    public function store(Request $request)
    {
        $validated = $request->validate([
            'id_profil' => 'nullable|exists:profil,id',
            'jenis_kegiatan' => 'required|string|max:255',
            'tanggal_mulai' => 'required|date',
            'tanggal_selesai' => 'required|date|after_or_equal:tanggal_mulai',
            'waktu_mulai' => 'required|date_format:H:i',
            'waktu_selesai' => 'required|date_format:H:i|after:waktu_mulai',
            'jenis_pestisida' => 'nullable|string|max:255',
            'target_penanaman' => 'required|integer|min:0',
            'keterangan' => 'nullable|string',
        ], [
            'jenis_kegiatan.required' => 'Jenis kegiatan wajib diisi',
            'tanggal_mulai.required' => 'Tanggal mulai wajib diisi',
            'tanggal_selesai.required' => 'Tanggal selesai wajib diisi',
            'tanggal_selesai.after_or_equal' => 'Tanggal selesai harus setelah atau sama dengan tanggal mulai',
            'waktu_mulai.required' => 'Waktu mulai wajib diisi',
            'waktu_selesai.required' => 'Waktu selesai wajib diisi',
            'waktu_selesai.after' => 'Waktu selesai harus setelah waktu mulai',
            'target_penanaman.required' => 'Target penanaman wajib diisi',
            'target_penanaman.integer' => 'Target penanaman harus berupa angka',
        ]);

        try {
            $kegiatan = Kegiatan::create($validated);

            if ($request->ajax()) {
                return response()->json([
                    'success' => true,
                    'message' => 'Kegiatan berhasil ditambahkan',
                    'data' => $kegiatan->load(['profil.user', 'buktiKegiatan']),
                ]);
            }

            return redirect()->route('admin.kegiatan.index')
                ->with('success', 'Kegiatan berhasil ditambahkan');
        } catch (\Exception $e) {
            if ($request->ajax()) {
                return response()->json([
                    'success' => false,
                    'message' => 'Gagal menambahkan kegiatan: ' . $e->getMessage(),
                ], 500);
            }

            return back()->withErrors(['error' => 'Gagal menambahkan kegiatan'])
                ->withInput();
        }
    }

    /**
     * Display the specified kegiatan
     */
    public function show(Kegiatan $kegiatan)
    {
        $kegiatan->load(['profil.user', 'profil.jabatan', 'buktiKegiatan']);

        return response()->json([
            'success' => true,
            'data' => $kegiatan,
        ]);
    }

    /**
     * Show form for editing kegiatan
     */
    public function edit(Kegiatan $kegiatan)
    {
        $kegiatan->load(['profil.user', 'buktiKegiatan']);
        $profils = Profil::with('user')->get();

        if (request()->ajax()) {
            return response()->json([
                'success' => true,
                'data' => $kegiatan,
                'profils' => $profils,
            ]);
        }

        return view('admin.kegiatan.edit', compact('kegiatan', 'profils'));
    }

    /**
     * Update the specified kegiatan
     */
    public function update(Request $request, Kegiatan $kegiatan)
    {
        $validated = $request->validate([
            'id_profil' => 'nullable|exists:profil,id',
            'jenis_kegiatan' => 'required|string|max:255',
            'tanggal_mulai' => 'required|date',
            'tanggal_selesai' => 'required|date|after_or_equal:tanggal_mulai',
            'waktu_mulai' => 'required|date_format:H:i',
            'waktu_selesai' => 'required|date_format:H:i',
            'jenis_pestisida' => 'nullable|string|max:255',
            'target_penanaman' => 'required|integer|min:0',
            'keterangan' => 'nullable|string',
        ]);

        try {
            $kegiatan->update($validated);

            if ($request->ajax()) {
                return response()->json([
                    'success' => true,
                    'message' => 'Kegiatan berhasil diperbarui',
                    'data' => $kegiatan->fresh()->load(['profil.user', 'buktiKegiatan']),
                ]);
            }

            return redirect()->route('admin.kegiatan.index')
                ->with('success', 'Kegiatan berhasil diperbarui');
        } catch (\Exception $e) {
            if ($request->ajax()) {
                return response()->json([
                    'success' => false,
                    'message' => 'Gagal memperbarui kegiatan: ' . $e->getMessage(),
                ], 500);
            }

            return back()->withErrors(['error' => 'Gagal memperbarui kegiatan'])
                ->withInput();
        }
    }

    /**
     * Remove the specified kegiatan
     */
    public function destroy(Request $request, Kegiatan $kegiatan)
    {
        try {
            $kegiatan->delete();

            if ($request->ajax()) {
                return response()->json([
                    'success' => true,
                    'message' => 'Kegiatan berhasil dihapus',
                ]);
            }

            return redirect()->route('admin.kegiatan.index')
                ->with('success', 'Kegiatan berhasil dihapus');
        } catch (\Exception $e) {
            if ($request->ajax()) {
                return response()->json([
                    'success' => false,
                    'message' => 'Gagal menghapus kegiatan: ' . $e->getMessage(),
                ], 500);
            }

            return back()->withErrors(['error' => 'Gagal menghapus kegiatan']);
        }
    }

    /**
     * Bulk delete kegiatan
     */
    public function bulkDestroy(Request $request)
    {
        $request->validate([
            'ids' => 'required|array',
            'ids.*' => 'exists:kegiatan,id',
        ]);

        try {
            Kegiatan::whereIn('id', $request->ids)->delete();

            return response()->json([
                'success' => true,
                'message' => count($request->ids) . ' kegiatan berhasil dihapus',
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Gagal menghapus kegiatan: ' . $e->getMessage(),
            ], 500);
        }
    }

    /**
     * Export kegiatan
     */
    public function export(Request $request)
    {
        $kegiatans = Kegiatan::with(['profil.user'])->get();

        $filename = 'kegiatan_' . date('Y-m-d_His') . '.csv';

        $headers = [
            'Content-Type' => 'text/csv',
            'Content-Disposition' => "attachment; filename=\"$filename\"",
        ];

        $callback = function () use ($kegiatans) {
            $file = fopen('php://output', 'w');
            fputcsv($file, ['ID', 'Jenis Kegiatan', 'Tanggal Mulai', 'Tanggal Selesai', 'Waktu', 'Target', 'Keterangan', 'Profil']);

            foreach ($kegiatans as $kegiatan) {
                fputcsv($file, [
                    $kegiatan->id,
                    $kegiatan->jenis_kegiatan,
                    $kegiatan->tanggal_mulai,
                    $kegiatan->tanggal_selesai,
                    $kegiatan->waktu_mulai . ' - ' . $kegiatan->waktu_selesai,
                    $kegiatan->target_penanaman,
                    $kegiatan->keterangan ?? '-',
                    $kegiatan->profil?->user?->nama_pengguna ?? '-',
                ]);
            }

            fclose($file);
        };

        return response()->stream($callback, 200, $headers);
    }
}
