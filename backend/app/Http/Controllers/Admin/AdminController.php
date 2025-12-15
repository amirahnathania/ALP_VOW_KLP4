<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\Admin;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Hash;
use Illuminate\Validation\Rule;

class AdminController extends Controller
{
    /**
     * Display a listing of admins
     */
    public function index(Request $request)
    {
        // Only superadmin can manage admins
        $adminUser = Auth::guard('admin')->user();
        if (!$adminUser || !($adminUser instanceof \App\Models\Admin) || !$adminUser->isSuperAdmin()) {
            abort(403, 'Unauthorized');
        }

        $query = Admin::query();

        // Search
        if ($request->filled('search')) {
            $search = $request->search;
            $query->where(function ($q) use ($search) {
                $q->where('name', 'like', "%{$search}%")
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

        $admins = $query->paginate(10)->withQueryString();

        if ($request->ajax()) {
            return response()->json([
                'success' => true,
                'html' => view('admin.admins._table', compact('admins'))->render(),
            ]);
        }

        return view('admin.admins.index', compact('admins'));
    }

    /**
     * Store a newly created admin
     */
    public function store(Request $request)
    {
        $adminUser = Auth::guard('admin')->user();
        if (!$adminUser || !($adminUser instanceof \App\Models\Admin) || !$adminUser->isSuperAdmin()) {
            return response()->json(['success' => false, 'message' => 'Unauthorized'], 403);
        }

        $validated = $request->validate([
            'name' => 'required|string|max:255',
            'email' => 'required|email|unique:admins,email',
            'password' => 'required|string|min:8|confirmed',
            'role' => 'required|in:superadmin,admin',
        ]);

        try {
            $admin = Admin::create($validated);

            return response()->json([
                'success' => true,
                'message' => 'Admin berhasil ditambahkan',
                'data' => $admin,
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Gagal menambahkan admin: ' . $e->getMessage(),
            ], 500);
        }
    }

    /**
     * Display the specified admin
     */
    public function show(Admin $admin)
    {
        return response()->json([
            'success' => true,
            'data' => $admin,
        ]);
    }

    /**
     * Update the specified admin
     */
    public function update(Request $request, Admin $admin)
    {
        $adminUser = Auth::guard('admin')->user();
        if (!$adminUser || !($adminUser instanceof \App\Models\Admin) || !$adminUser->isSuperAdmin()) {
            return response()->json(['success' => false, 'message' => 'Unauthorized'], 403);
        }

        $validated = $request->validate([
            'name' => 'required|string|max:255',
            'email' => ['required', 'email', Rule::unique('admins')->ignore($admin->id)],
            'password' => 'nullable|string|min:8|confirmed',
            'role' => 'required|in:superadmin,admin',
            'is_active' => 'boolean',
        ]);

        try {
            $updateData = [
                'name' => $validated['name'],
                'email' => $validated['email'],
                'role' => $validated['role'],
                'is_active' => $validated['is_active'] ?? $admin->is_active,
            ];

            if (!empty($validated['password'])) {
                $updateData['password'] = $validated['password'];
            }

            $admin->update($updateData);

            return response()->json([
                'success' => true,
                'message' => 'Admin berhasil diperbarui',
                'data' => $admin->fresh(),
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Gagal memperbarui admin: ' . $e->getMessage(),
            ], 500);
        }
    }

    /**
     * Remove the specified admin
     */
    public function destroy(Admin $admin)
    {
        $adminUser = Auth::guard('admin')->user();
        if (!$adminUser || !($adminUser instanceof \App\Models\Admin) || !$adminUser->isSuperAdmin()) {
            return response()->json(['success' => false, 'message' => 'Unauthorized'], 403);
        }

        // Prevent deleting self
        if ($admin->id === Auth::guard('admin')->id()) {
            return response()->json([
                'success' => false,
                'message' => 'Tidak dapat menghapus akun sendiri',
            ], 400);
        }

        try {
            $admin->delete();

            return response()->json([
                'success' => true,
                'message' => 'Admin berhasil dihapus',
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Gagal menghapus admin: ' . $e->getMessage(),
            ], 500);
        }
    }

    /**
     * Toggle admin active status
     */
    public function toggleStatus(Admin $admin)
    {
        $adminUser = Auth::guard('admin')->user();
        if (!$adminUser || !($adminUser instanceof \App\Models\Admin) || !$adminUser->isSuperAdmin()) {
            return response()->json(['success' => false, 'message' => 'Unauthorized'], 403);
        }

        // Prevent deactivating self
        if ($admin->id === Auth::guard('admin')->id()) {
            return response()->json([
                'success' => false,
                'message' => 'Tidak dapat menonaktifkan akun sendiri',
            ], 400);
        }

        try {
            $admin->update(['is_active' => !$admin->is_active]);

            return response()->json([
                'success' => true,
                'message' => 'Status admin berhasil diubah',
                'data' => $admin->fresh(),
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Gagal mengubah status admin: ' . $e->getMessage(),
            ], 500);
        }
    }

    /**
     * Show profile page
     */
    public function showProfile()
    {
        return view('admin.profile');
    }

    /**
     * Update profile
     */
    public function updateProfile(Request $request)
    {
        $admin = Auth::guard('admin')->user();

        $validated = $request->validate([
            'name' => 'required|string|max:255',
            'email' => ['required', 'email', Rule::unique('admins')->ignore($admin->id)],
            'current_password' => 'required_with:new_password',
            'new_password' => 'nullable|string|min:8|confirmed',
        ]);

        try {
            if (!empty($validated['current_password'])) {
                if (!Hash::check($validated['current_password'], $admin->password)) {
                    return response()->json([
                        'success' => false,
                        'message' => 'Password saat ini salah',
                    ], 422);
                }
            }

            $updateData = [
                'name' => $validated['name'],
                'email' => $validated['email'],
            ];

            if (!empty($validated['new_password'])) {
                $updateData['password'] = $validated['new_password'];
            }

            $admin->update($updateData);

            return response()->json([
                'success' => true,
                'message' => 'Profil berhasil diperbarui',
                'data' => $admin->fresh(),
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Gagal memperbarui profil: ' . $e->getMessage(),
            ], 500);
        }
    }
}
