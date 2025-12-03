<?php

namespace App\Http\Controllers;

use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;

class UserController extends Controller
{
    // GET /api/users
    public function index()
    {
        $users = User::with('profil')->get();
        return response()->json([
            'success' => true,
            'data' => $users
        ]);
    }

    // POST /api/users
    // app/Http/Controllers/UserController.php
    public function store(Request $request)
    {
        $request->validate([
            'name' => 'required|string|max:255',
            'email' => [
                'required',
                'string',
                'email',
                'max:255',
                'unique:users,Email',
                function ($attribute, $value, $fail) {
                    $allowedDomains = ['ketua.ac.id', 'gapoktan.ac.id'];
                    $domain = substr(strrchr($value, "@"), 1);
                    
                    if (!in_array($domain, $allowedDomains)) {
                        $fail('Email harus menggunakan domain @ketua.ac.id atau @gapoktan.ac.id');
                    }
                }
            ],
            'password' => 'required|string|min:8|confirmed',
        ]);

        // Auto-set role
        $domain = substr(strrchr($request->email, "@"), 1);
        $role = ($domain == 'ketua.ac.id') ? 'ketua' : 'gapoktan';

        $user = User::create([
            'Nama_Pengguna' => $request->name,
            'Email' => $request->email,
            'Kata_Sandi' => Hash::make($request->password),
            'role' => $role,
        ]);

        $token = $user->createToken('auth_token')->plainTextToken;

        return response()->json([
            'message' => 'Registrasi berhasil',
            'user' => $user,
            'token' => $token,
            'token_type' => 'Bearer',
        ], 201);
    }

    // GET /api/users/{id}
    public function show($id)
    {
        $user = User::with('profil')->find($id);
        
        if (!$user) {
            return response()->json([
                'success' => false,
                'message' => 'User not found'
            ], 404);
        }

        return response()->json([
            'success' => true,
            'data' => $user
        ]);
    }

    // PUT/PATCH /api/users/{id}
    public function update(Request $request, $id)
    {
        $user = User::find($id);
        
        if (!$user) {
            return response()->json([
                'success' => false,
                'message' => 'User not found'
            ], 404);
        }

        $request->validate([
            'Nama_Pengguna' => 'sometimes|string|max:255',
            'Email' => 'sometimes|email|unique:users,Email,' . $id . ',Id_User',
            'Kata_Sandi' => 'sometimes|string|min:6',
        ]);

        $data = $request->only(['Nama_Pengguna', 'Email']);
        
        if ($request->has('Kata_Sandi')) {
            $data['Kata_Sandi'] = Hash::make($request->Kata_Sandi);
        }

        $user->update($data);

        return response()->json([
            'success' => true,
            'message' => 'User updated successfully',
            'data' => $user
        ]);
    }

    // DELETE /api/users/{id}
    public function destroy($id)
    {
        $user = User::find($id);
        
        if (!$user) {
            return response()->json([
                'success' => false,
                'message' => 'User not found'
            ], 404);
        }

        $user->delete();

        return response()->json([
            'success' => true,
            'message' => 'User deleted successfully'
        ]);
    }
}