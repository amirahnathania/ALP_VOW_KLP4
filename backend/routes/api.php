<?php

use Illuminate\Support\Facades\Route;
use Illuminate\Http\Request; 
use App\Http\Controllers\UserController;
use App\Http\Controllers\JabatanController;
use App\Http\Controllers\ProfilController;
use App\Http\Controllers\KegiatanController;
use App\Http\Controllers\BuktiKegiatanController;

// Test route
Route::get('/test', function () {
    return response()->json(['message' => 'API is working!']);
});

// ========== LOGIN ROUTE ==========
Route::post('/users/login', function (Request $request) {
    $request->validate([
        'Email' => 'required|email',
        'Kata_Sandi' => 'required',
        'device_name' => 'required',
    ]);

    $user = \App\Models\User::where('Email', $request->Email)->first();

    if (!$user || !\Illuminate\Support\Facades\Hash::check($request->Kata_Sandi, $user->Kata_Sandi)) {
        return response()->json(['message' => 'Email atau password salah'], 401);
    }

    $token = $user->createToken($request->device_name)->plainTextToken;

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
});
// ========== END LOGIN ==========

// API Routes untuk User, Jabatan, Profil, Kegiatan, dan Bukti Kegiatan
Route::apiResource('users', UserController::class);
Route::apiResource('jabatan', JabatanController::class);
Route::apiResource('profil', ProfilController::class);
Route::apiResource('kegiatans', KegiatanController::class);
Route::apiResource('bukti_kegiatans', BuktiKegiatanController::class);