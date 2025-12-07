<?php

namespace App\Http\Controllers;

use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Validator;
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
        // Validasi akan dihandle oleh Handler.php secara global
        $validated = $request->validate([
            'Nama_Pengguna' => [
                'required',
                'string',
                'min:3',
                'max:50',
                'regex:/^[a-zA-Z\s\.]+$/'
            ],
            'Email' => [
                'required',
                'max:100',
                'unique:users,Email',
                function ($attribute, $value, $fail) {
                    $allowedDomains = ['ketua.ac.id', 'gapoktan.ac.id'];
                    $domain = substr(strrchr($value, "@"), 1);
                    
                    if (!in_array($domain, $allowedDomains)) {
                        $fail('Email harus menggunakan domain @ketua.ac.id atau @gapoktan.ac.id');
                    }
                }
            ],
            'Kata_Sandi' => [
                'required',
                'string',
                'min:8',
                'max:32',
                'confirmed',
                'regex:/^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)[A-Za-z\d@$!%*?&]+$/'
            ],
            'Kata_Sandi_confirmation' => 'required|string|same:Kata_Sandi'
        ], [
            'Nama_Pengguna.required' => 'Nama pengguna wajib diisi',
            'Nama_Pengguna.min' => 'Nama pengguna minimal 3 karakter',
            'Nama_Pengguna.max' => 'Nama pengguna maksimal 50 karakter',
            'Nama_Pengguna.regex' => 'Nama hanya boleh mengandung huruf, spasi, dan titik',
            
            'Email.required' => 'Email wajib diisi',
            'Email.email' => 'Format email tidak valid',
            'Email.max' => 'Email maksimal 100 karakter',
            'Email.unique' => 'Email sudah terdaftar',
            
            'Kata_Sandi.required' => 'Kata sandi wajib diisi',
            'Kata_Sandi.min' => 'Kata sandi minimal 8 karakter',
            'Kata_Sandi.max' => 'Kata sandi maksimal 32 karakter',
            'Kata_Sandi.confirmed' => 'Konfirmasi kata sandi tidak sesuai',
            'Kata_Sandi.regex' => 'Kata sandi harus mengandung minimal 1 huruf besar, 1 huruf kecil, dan 1 angka',
            
            'Kata_Sandi_confirmation.required' => 'Konfirmasi kata sandi wajib diisi',
            'Kata_Sandi_confirmation.same' => 'Konfirmasi kata sandi tidak sesuai'
        ]);

        try {
            $user = User::create([
                'Nama_Pengguna' => $validated['Nama_Pengguna'],
                'Email' => $validated['Email'],
                'Kata_Sandi' => Hash::make($validated['Kata_Sandi']),
            ]);

            $token = $user->createToken('auth_token')->plainTextToken;

            return response()->json([
                'success' => true,
                'message' => 'Registrasi berhasil',
                'data' => [
                    'id' => $user->Id_User,
                    'nama' => $user->Nama_Pengguna,
                    'email' => $user->Email,
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

            $userData = [
                'id' => $user->Id_User,
                'nama' => $user->Nama_Pengguna,
                'email' => $user->Email,
                'email_verified_at' => $user->email_verified_at,
                'created_at' => $user->created_at,
                'updated_at' => $user->updated_at,
                'profil' => $user->profil
            ];

            return response()->json([
                'success' => true,
                'data' => $userData
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
            'Nama_Pengguna' => [
                'sometimes',
                'required',
                'string',
                'min:3',
                'max:50',
                'regex:/^[a-zA-Z\s\.]+$/'
            ],
            'Email' => [
                'sometimes',
                'required',
                'email',
                'max:100',
                Rule::unique('users', 'Email')->ignore($id, 'Id_User'),
                function ($attribute, $value, $fail) {
                    $allowedDomains = ['ketua.ac.id', 'gapoktan.ac.id'];
                    $domain = substr(strrchr($value, "@"), 1);
                    
                    if (!in_array($domain, $allowedDomains)) {
                        $fail('Email harus menggunakan domain @ketua.ac.id atau @gapoktan.ac.id');
                    }
                }
            ],
            'Kata_Sandi' => [
                'sometimes',
                'required',
                'string',
                'min:8',
                'max:32',
                'regex:/^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)[A-Za-z\d@$!%*?&]+$/'
            ]
        ], [
            'Nama_Pengguna.min' => 'Nama pengguna minimal 3 karakter',
            'Nama_Pengguna.max' => 'Nama pengguna maksimal 50 karakter',
            'Nama_Pengguna.regex' => 'Nama hanya boleh mengandung huruf, spasi, dan titik',
            'Kata_Sandi.min' => 'Kata sandi minimal 8 karakter',
            'Kata_Sandi.max' => 'Kata sandi maksimal 32 karakter',
            'Kata_Sandi.regex' => 'Kata sandi harus mengandung minimal 1 huruf besar, 1 huruf kecil, dan 1 angka'
        ]);

        try {
            $data = [];
            
            if ($request->has('Nama_Pengguna')) {
                $data['Nama_Pengguna'] = $validated['Nama_Pengguna'];
            }
            
            if ($request->has('Email')) {
                $data['Email'] = $validated['Email'];
            }
            
            if ($request->has('Kata_Sandi')) {
                $data['Kata_Sandi'] = Hash::make($validated['Kata_Sandi']);
            }

            $user->update($data);

            return response()->json([
                'success' => true,
                'message' => 'Data pengguna berhasil diperbarui',
                'data' => [
                    'id' => $user->Id_User,
                    'nama' => $user->Nama_Pengguna,
                    'email' => $user->Email
                ]
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
            'Email' => [
                'required',
                'email',
                'max:100',
                function ($attribute, $value, $fail) {
                    $allowedDomains = ['ketua.ac.id', 'gapoktan.ac.id'];
                    $domain = substr(strrchr($value, "@"), 1);
                    
                    if (!in_array($domain, $allowedDomains)) {
                        $fail('Email harus menggunakan domain @ketua.ac.id atau @gapoktan.ac.id');
                    }
                }
            ],
            'Kata_Sandi' => [
                'required',
                'string',
                'min:8',
                'max:32'
            ]
        ], [
            'Email.required' => 'Email wajib diisi',
            'Email.email' => 'Format email tidak valid',
            'Email.max' => 'Email maksimal 100 karakter',
            'Kata_Sandi.required' => 'Kata sandi wajib diisi',
            'Kata_Sandi.min' => 'Kata sandi minimal 8 karakter',
            'Kata_Sandi.max' => 'Kata sandi maksimal 32 karakter'
        ]);

        try {
            $user = User::where('Email', $validated['Email'])->first();

            if (!$user || !Hash::check($validated['Kata_Sandi'], $user->Kata_Sandi)) {
                return response()->json([
                    'success' => false,
                    'message' => 'Email atau kata sandi salah'
                ], 401);
            }

            $token = $user->createToken('auth_token')->plainTextToken;

            return response()->json([
                'success' => true,
                'message' => 'Login berhasil',
                'data' => [
                    'id' => $user->Id_User,
                    'nama' => $user->Nama_Pengguna,
                    'email' => $user->Email
                ],
                'token' => $token,
                'token_type' => 'Bearer',
            ]);
            
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Gagal login',
                'error' => $e->getMessage()
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