<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\User;
use App\Models\Profil;
use App\Models\Jabatan;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use Illuminate\Validation\Rule;

class UserController extends Controller
{
    /**
     * Display a listing of users
     */
    public function index(Request $request)
    {
        $query = User::with(['profil.jabatan']);

        // Search
        if ($request->filled('search')) {
            $search = $request->search;
            $query->where(function ($q) use ($search) {
                $q->where('nama_pengguna', 'like', "%{$search}%")
                    ->orWhere('email', 'like', "%{$search}%");
            });
        }

        // Filter by role
        if ($request->filled('role')) {
            $query->where('role', $request->role);
        }

        // Sort
        $sortField = $request->get('sort', 'created_at');
        $sortDirection = $request->get('direction', 'desc');
        $query->orderBy($sortField, $sortDirection);

        $users = $query->paginate(10)->withQueryString();
        $jabatans = Jabatan::all();

        if ($request->ajax()) {
            return response()->json([
                'success' => true,
                'html' => view('admin.users._table', compact('users'))->render(),
                'pagination' => view('admin.partials._pagination', compact('users'))->render(),
            ]);
        }

        return view('admin.users.index', compact('users', 'jabatans'));
    }

    /**
     * Show form for creating new user
     */
    public function create()
    {
        $jabatans = Jabatan::all();
        return view('admin.users.create', compact('jabatans'));
    }

    /**
     * Store a newly created user
     */
    public function store(Request $request)
    {
        $validated = $request->validate([
            'nama_pengguna' => 'required|string|min:3|max:50',
            'email' => 'required|email|unique:users,email',
            'password' => 'required|string|min:8|confirmed',
            'role' => 'required|in:ketua,gapoktan',
            'id_jabatan' => 'nullable|exists:jabatan,id',
        ], [
            'nama_pengguna.required' => 'Nama pengguna wajib diisi',
            'email.required' => 'Email wajib diisi',
            'email.unique' => 'Email sudah digunakan',
            'password.required' => 'Password wajib diisi',
            'password.min' => 'Password minimal 8 karakter',
            'password.confirmed' => 'Konfirmasi password tidak sesuai',
            'role.required' => 'Role wajib dipilih',
        ]);

        try {
            $user = User::create([
                'nama_pengguna' => $validated['nama_pengguna'],
                'email' => $validated['email'],
                'password' => $validated['password'],
                'role' => $validated['role'],
            ]);

            // Create profil if jabatan is provided
            if (!empty($validated['id_jabatan'])) {
                Profil::create([
                    'id_user' => $user->id,
                    'id_jabatan' => $validated['id_jabatan'],
                ]);
            }

            if ($request->ajax()) {
                return response()->json([
                    'success' => true,
                    'message' => 'User berhasil ditambahkan',
                    'data' => $user->load('profil.jabatan'),
                ]);
            }

            return redirect()->route('admin.users.index')
                ->with('success', 'User berhasil ditambahkan');
        } catch (\Exception $e) {
            if ($request->ajax()) {
                return response()->json([
                    'success' => false,
                    'message' => 'Gagal menambahkan user: ' . $e->getMessage(),
                ], 500);
            }

            return back()->withErrors(['error' => 'Gagal menambahkan user'])
                ->withInput();
        }
    }

    /**
     * Display the specified user
     */
    public function show(User $user)
    {
        $user->load(['profil.jabatan']);

        return response()->json([
            'success' => true,
            'data' => $user,
        ]);
    }

    /**
     * Show form for editing user
     */
    public function edit(User $user)
    {
        $user->load('profil.jabatan');
        $jabatans = Jabatan::all();

        if (request()->ajax()) {
            return response()->json([
                'success' => true,
                'data' => $user,
                'jabatans' => $jabatans,
            ]);
        }

        return view('admin.users.edit', compact('user', 'jabatans'));
    }

    /**
     * Update the specified user
     */
    public function update(Request $request, User $user)
    {
        $validated = $request->validate([
            'nama_pengguna' => 'required|string|min:3|max:50',
            'email' => ['required', 'email', Rule::unique('users')->ignore($user->id)],
            'password' => 'nullable|string|min:8|confirmed',
            'role' => 'required|in:ketua,gapoktan',
            'id_jabatan' => 'nullable|exists:jabatan,id',
        ]);

        try {
            $updateData = [
                'nama_pengguna' => $validated['nama_pengguna'],
                'email' => $validated['email'],
                'role' => $validated['role'],
            ];

            if (!empty($validated['password'])) {
                $updateData['password'] = $validated['password'];
            }

            $user->update($updateData);

            // Update or create profil
            if (!empty($validated['id_jabatan'])) {
                $user->profil()->updateOrCreate(
                    ['id_user' => $user->id],
                    ['id_jabatan' => $validated['id_jabatan']]
                );
            }

            if ($request->ajax()) {
                return response()->json([
                    'success' => true,
                    'message' => 'User berhasil diperbarui',
                    'data' => $user->fresh()->load('profil.jabatan'),
                ]);
            }

            return redirect()->route('admin.users.index')
                ->with('success', 'User berhasil diperbarui');
        } catch (\Exception $e) {
            if ($request->ajax()) {
                return response()->json([
                    'success' => false,
                    'message' => 'Gagal memperbarui user: ' . $e->getMessage(),
                ], 500);
            }

            return back()->withErrors(['error' => 'Gagal memperbarui user'])
                ->withInput();
        }
    }

    /**
     * Remove the specified user
     */
    public function destroy(Request $request, User $user)
    {
        try {
            $user->delete();

            if ($request->ajax()) {
                return response()->json([
                    'success' => true,
                    'message' => 'User berhasil dihapus',
                ]);
            }

            return redirect()->route('admin.users.index')
                ->with('success', 'User berhasil dihapus');
        } catch (\Exception $e) {
            if ($request->ajax()) {
                return response()->json([
                    'success' => false,
                    'message' => 'Gagal menghapus user: ' . $e->getMessage(),
                ], 500);
            }

            return back()->withErrors(['error' => 'Gagal menghapus user']);
        }
    }

    /**
     * Bulk delete users
     */
    public function bulkDestroy(Request $request)
    {
        $request->validate([
            'ids' => 'required|array',
            'ids.*' => 'exists:users,id',
        ]);

        try {
            User::whereIn('id', $request->ids)->delete();

            return response()->json([
                'success' => true,
                'message' => count($request->ids) . ' user berhasil dihapus',
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Gagal menghapus user: ' . $e->getMessage(),
            ], 500);
        }
    }

    /**
     * Export users
     */
    public function export(Request $request)
    {
        $users = User::with('profil.jabatan')->get();

        $filename = 'users_' . date('Y-m-d_His') . '.csv';

        $headers = [
            'Content-Type' => 'text/csv',
            'Content-Disposition' => "attachment; filename=\"$filename\"",
        ];

        $callback = function () use ($users) {
            $file = fopen('php://output', 'w');
            fputcsv($file, ['ID', 'Nama', 'Email', 'Role', 'Jabatan', 'Created At']);

            foreach ($users as $user) {
                fputcsv($file, [
                    $user->id,
                    $user->nama_pengguna,
                    $user->email,
                    $user->role,
                    $user->profil?->jabatan?->jabatan ?? '-',
                    $user->created_at->format('Y-m-d H:i:s'),
                ]);
            }

            fclose($file);
        };

        return response()->stream($callback, 200, $headers);
    }
}
