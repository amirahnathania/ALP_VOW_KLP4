<?php

namespace App\Http\Controllers;

use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use Illuminate\Validation\Rule;

class UserController extends Controller
{
    // GET /api/users
    public function index()
    {
        try {
            $users = User::with('profil')->get();
            return response()->json([
                'success' => true,
                'data' => $users
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
    public function store(Request $request)
    {
        $validated = $request->validate([
            'nama_pengguna' => [
                'required',
                'string',
                'min:3',
                'max:50',
                'regex:/^[a-zA-Z\s\.]+$/'
            ],
            'email' => [
                'required',
                'email',
                'max:100',
                'unique:users,email',
                function ($attribute, $value, $fail) {
                    $allowedDomains = ['ketua.ac.id', 'gapoktan.ac.id'];
                    $domain = substr(strrchr($value, "@"), 1);

                    if (!in_array($domain, $allowedDomains)) {
                        $fail('email harus menggunakan domain @ketua.ac.id atau @gapoktan.ac.id');
                    }
                }
            ],
            'password' => [
                'required',
                'string',
                'min:8',
                'max:32',
                'confirmed',
                'regex:/^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)[A-Za-z\d@$!%*?&]+$/'
            ],
            'password_confirmation' => 'required|string|same:password'
        ], [
            'nama_pengguna.required' => 'Nama pengguna wajib diisi',
            'nama_pengguna.min' => 'Nama pengguna minimal 3 karakter',
            'nama_pengguna.max' => 'Nama pengguna maksimal 50 karakter',
            'nama_pengguna.regex' => 'Nama hanya boleh mengandung huruf, spasi, dan titik',

            'email.required' => 'Email wajib diisi',
            'email.email' => 'Format email tidak valid',
            'email.max' => 'Email maksimal 100 karakter',
            'email.unique' => 'Email sudah terdaftar',

            'password.required' => 'Password wajib diisi',
            'password.min' => 'Password minimal 8 karakter',
            'password.max' => 'Password maksimal 32 karakter',
            'password.confirmed' => 'Konfirmasi password tidak sesuai',
            'password.regex' => 'Password harus mengandung minimal 1 huruf besar, 1 huruf kecil, dan 1 angka',

            'password_confirmation.required' => 'Konfirmasi password wajib diisi',
            'password_confirmation.same' => 'Konfirmasi password tidak sesuai'
        ]);

        try {
            $user = User::create([
                'nama_pengguna' => $validated['nama_pengguna'],
                'email' => $validated['email'],
                'password' => $validated['password'],
            ]);

            $token = $user->createToken('auth_token')->plainTextToken;

            return response()->json([
                'success' => true,
                'message' => 'Registrasi berhasil',
                'data' => [
                    'id' => $user->id,
                    'nama_pengguna' => $user->nama_pengguna,
                    'email' => $user->email,
                    'role' => $user->role,
                    'created_at' => $user->created_at
                ],
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
            $user = User::with('profil')->find($id);

            if (!$user) {
                return response()->json([
                    'success' => false,
                    'message' => 'Pengguna tidak ditemukan'
                ], 404);
            }

            return response()->json([
                'success' => true,
                'data' => $user
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
                'data' => $user
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
    public function login(Request $request)
    {
        $validated = $request->validate([
            'email' => [
                'required',
                'email',
                'max:100',
                function ($attribute, $value, $fail) {
                    $allowedDomains = ['ketua.ac.id', 'gapoktan.ac.id'];
                    $domain = substr(strrchr($value, "@"), 1);
                    if (!in_array($domain, $allowedDomains)) {
                        $fail('email harus menggunakan domain @ketua.ac.id atau @gapoktan.ac.id');
                    }
                }
            ],
            'password' => [
                'required',
                'string',
                'min:8',
                'max:32'
            ]
        ], [
            'email.required' => 'Email wajib diisi',
            'email.email' => 'Format email tidak valid',
            'email.max' => 'Email maksimal 100 karakter',
            'password.required' => 'Password wajib diisi',
            'password.min' => 'Password minimal 8 karakter',
            'password.max' => 'Password maksimal 32 karakter'
        ]);

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

            return response()->json([
                'success' => true,
                'message' => 'Login berhasil',
                'data' => [
                    'id' => $user->id,
                    'nama_pengguna' => $user->nama_pengguna,
                    'email' => $user->email,
                    'role' => $user->role
                ],
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
}
