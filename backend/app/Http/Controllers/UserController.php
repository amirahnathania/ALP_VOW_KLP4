<?php

namespace App\Http\Controllers;

use App\Models\User;
use Illuminate\Http\Request;
use App\Http\Requests\LoginRequest;
use App\Http\Requests\RegisterRequest;
use App\Http\Resources\UserResource;
use App\Models\Profil;
use App\Models\Jabatan;
use Illuminate\Support\Facades\Hash;
use Illuminate\Validation\Rule;

class UserController extends Controller
{
    // GET /api/users
    public function index()
    {
        try {
            // Eager-load profil and nested jabatan to provide jabatan details
            $users = User::with('profil.jabatan')->get();
            return response()->json([
                'success' => true,
                'data' => UserResource::collection($users)
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Gagal mengambil data pengguna',
                'error' => $e->getMessage()
            ], 500);
        }
    }

    // POST /api/users (REGISTER)
    public function store(RegisterRequest $request)
    {
        $validated = $request->validated();


        try {
            $user = User::create([
                'nama_pengguna' => $validated['nama_pengguna'],
                'email' => $validated['email'],
                'password' => $validated['password'],
            ]);

            $token = $user->createToken('auth_token')->plainTextToken;

            // Ensure the user has a profil. Use an active Jabatan if available, otherwise the first Jabatan.
            try {
                if (!Profil::userHasProfile($user->id)) {
                    $jabatan = Jabatan::aktif()->first() ?? Jabatan::first();
                    if (!$jabatan) {
                        // create a fallback jabatan so a profil can be created
                        $jabatan = Jabatan::create([
                            'jabatan' => 'Anggota Sementara',
                            'awal_jabatan' => now()->format('Y-m-d'),
                            'akhir_jabatan' => null,
                        ]);
                    }
                    Profil::create([
                        'id_user' => $user->id,
                        'id_jabatan' => $jabatan->id,
                    ]);
                }
            } catch (\Exception $e) {
                // Non-fatal: we still return success
            }

            // Reload user with profil relation to ensure resource contains it
            $user = User::with('profil.jabatan')->find($user->id);

            return response()->json([
                'success' => true,
                'message' => 'Registrasi berhasil',
                'data' => new UserResource($user),
                'token' => $token,
                'token_type' => 'Bearer',
            ], 201);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Gagal melakukan registrasi',
                'error' => $e->getMessage()
            ], 500);
        }
    }

    // GET /api/users/{id}
    public function show($id)
    {
        try {
            // Eager-load profil and nested jabatan so frontend receives jabatan data
            $user = User::with('profil.jabatan')->find($id);

            if (!$user) {
                return response()->json([
                    'success' => false,
                    'message' => 'Pengguna tidak ditemukan'
                ], 404);
            }

            return response()->json([
                'success' => true,
                'data' => new UserResource($user)
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Gagal mengambil data pengguna',
                'error' => $e->getMessage()
            ], 500);
        }
    }

    // PUT/PATCH /api/users/{id}
    public function update(Request $request, $id)
    {
        $user = User::find($id);

        if (!$user) {
            return response()->json([
                'success' => false,
                'message' => 'Pengguna tidak ditemukan'
            ], 404);
        }

        $validated = $request->validate([
            'nama_pengguna' => [
                'sometimes',
                'required',
                'string',
                'min:3',
                'max:50',
                'regex:/^[a-zA-Z\s\.]+$/'
            ],
            'email' => [
                'sometimes',
                'required',
                'email',
                'max:100',
                Rule::unique('users', 'email')->ignore($id),
                function ($attribute, $value, $fail) {
                    $allowedDomains = ['ketua.ac.id', 'gapoktan.ac.id'];
                    $domain = substr(strrchr($value, "@"), 1);

                    if (!in_array($domain, $allowedDomains)) {
                        $fail('email harus menggunakan domain @ketua.ac.id atau @gapoktan.ac.id');
                    }
                }
            ],
            'password' => [
                'sometimes',
                'required',
                'string',
                'min:8',
                'max:32',
                'regex:/^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)[A-Za-z\d@$!%*?&]+$/'
            ]
        ], [
            'nama_pengguna.min' => 'Nama pengguna minimal 3 karakter',
            'nama_pengguna.max' => 'Nama pengguna maksimal 50 karakter',
            'nama_pengguna.regex' => 'Nama hanya boleh mengandung huruf, spasi, dan titik',
            'password.min' => 'Password minimal 8 karakter',
            'password.max' => 'Password maksimal 32 karakter',
            'password.regex' => 'Password harus mengandung minimal 1 huruf besar, 1 huruf kecil, dan 1 angka'
        ]);

        try {
            $data = [];

            if ($request->has('nama_pengguna')) {
                $data['nama_pengguna'] = $validated['nama_pengguna'];
            }

            if ($request->has('email')) {
                $data['email'] = $validated['email'];
            }

            if ($request->has('password')) {
                $data['password'] = $validated['password'];
            }

            $user->update($data);

            return response()->json([
                'success' => true,
                'message' => 'Data pengguna berhasil diperbarui',
                'data' => new UserResource($user)
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Gagal memperbarui data pengguna',
                'error' => $e->getMessage()
            ], 500);
        }
    }

    // DELETE /api/users/{id}
    public function destroy($id)
    {
        try {
            $user = User::find($id);

            if (!$user) {
                return response()->json([
                    'success' => false,
                    'message' => 'Pengguna tidak ditemukan'
                ], 404);
            }

            if ($user->profil) {
                return response()->json([
                    'success' => false,
                    'message' => 'Pengguna memiliki profil terkait. Hapus profil terlebih dahulu.'
                ], 400);
            }

            $user->delete();

            return response()->json([
                'success' => true,
                'message' => 'Pengguna berhasil dihapus'
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Gagal menghapus pengguna',
                'error' => $e->getMessage()
            ], 500);
        }
    }

    // POST /api/login
    public function login(LoginRequest $request)
    {
        $validated = $request->validated();


        try {
            $user = User::where('email', $validated['email'])->first();

            if (!$user) {
                return response()->json([
                    'success' => false,
                    'message' => 'Email tidak ditemukan'
                ], 401);
            }

            if (!Hash::check($validated['password'], $user->password)) {
                return response()->json([
                    'success' => false,
                    'message' => 'Password salah'
                ], 401);
            }

            $token = $user->createToken('auth_token', ['*'], now()->addDays(7))->plainTextToken;

            // Auto-create profil if missing (choose an active Jabatan or fallback to first)
            try {
                if (!Profil::userHasProfile($user->id)) {
                    $jabatan = Jabatan::aktif()->first() ?? Jabatan::first();
                    if (!$jabatan) {
                        $jabatan = Jabatan::create([
                            'jabatan' => 'Anggota Sementara',
                            'awal_jabatan' => now()->format('Y-m-d'),
                            'akhir_jabatan' => null,
                        ]);
                    }
                    Profil::create([
                        'id_user' => $user->id,
                        'id_jabatan' => $jabatan->id,
                    ]);
                }
            } catch (\Exception $e) {
                // ignore profil create errors for now
            }

            // Re-load the user with profil.jabatan to ensure resource includes it
            $user = User::with('profil.jabatan')->find($user->id);

            return response()->json([
                'success' => true,
                'message' => 'Login berhasil',
                'data' => new UserResource($user),
                'token' => $token,
                'token_type' => 'Bearer',
                'expires_in' => 604800
            ], 200);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Terjadi kesalahan pada server'
            ], 500);
        }
    }

    // POST /api/logout
    public function logout(Request $request)
    {
        try {
            $request->user()->currentAccessToken()->delete();

            return response()->json([
                'success' => true,
                'message' => 'Logout berhasil'
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Gagal logout',
                'error' => $e->getMessage()
            ], 500);
        }
    }

    // GET /api/users/{id}/ensure-profil
    public function ensureProfil($id)
    {
        try {
            $user = User::find($id);
            if (!$user) {
                return response()->json([
                    'success' => false,
                    'message' => 'Pengguna tidak ditemukan'
                ], 404);
            }

            try {
                if (!Profil::userHasProfile($user->id)) {
                    $jabatan = Jabatan::aktif()->first() ?? Jabatan::first();
                    if (!$jabatan) {
                        $jabatan = Jabatan::create([
                            'jabatan' => 'Anggota Sementara',
                            'awal_jabatan' => now()->format('Y-m-d'),
                            'akhir_jabatan' => null,
                        ]);
                    }
                    Profil::create([
                        'id_user' => $user->id,
                        'id_jabatan' => $jabatan->id,
                    ]);
                }
            } catch (\Exception $e) {
                // ignore creation errors
            }

            // reload user with relation to ensure resource contains profil
            $user = User::with('profil.jabatan')->find($user->id);

            return response()->json([
                'success' => true,
                'data' => new UserResource($user)
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Gagal memastikan profil pengguna',
                'error' => $e->getMessage()
            ], 500);
        }
    }
}
