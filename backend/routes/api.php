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
        'email' => 'required|email',
        'password' => 'required',
        'device_name' => 'required',
    ]);

    $user = \App\Models\User::where('email', $request->email)->first();

    if (!$user || !\Illuminate\Support\Facades\Hash::check($request->password, $user->password)) {
        return response()->json(['message' => 'Email atau password salah'], 401);
    }

    $token = $user->createToken($request->device_name)->plainTextToken;

    return response()->json([
        'message' => 'Login berhasil',
        'user' => $user,
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