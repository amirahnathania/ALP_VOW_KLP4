<?php

use Illuminate\Support\Facades\Route;
use Illuminate\Http\Request; 
use App\Http\Controllers\UserController;
use App\Http\Controllers\JabatanController;
use App\Http\Controllers\ProfilController; // ← PERHATIKAN TIDAK ADA SPASI
use App\Http\Controllers\KegiatanController;
use App\Http\Controllers\BuktiKegiatanController;

// Test route
Route::get('/test', function () {
    return response()->json(['message' => 'API is working!']);
});

Route::post('/users', [UserController::class, 'store']);

// LOGIN ROUTE - FIXED
Route::post('/users/login', function (Request $request) {
    $request->validate([
        'email' => 'required|email',
        'password' => 'required',
        'device_name' => 'required',
    ]);

    $user = \App\Models\User::where('Email', $request->email)->first();

    if (!$user || !\Illuminate\Support\Facades\Hash::check($request->password, $user->Kata_Sandi)) {
        return response()->json(['message' => 'Email atau password salah'], 401);
    }

    $token = $user->createToken($request->device_name)->plainTextToken;

    return response()->json([
        'message' => 'Login berhasil',
        'user' => $user,
        'token' => $token,
        'token_type' => 'Bearer',
    ]);
})->name('login');

// ========== PROTECTED ROUTES (Dengan Auth Sanctum) ==========
Route::middleware('auth:sanctum')->group(function () {
    // User routes
    Route::get('/users', [UserController::class, 'index']);
    Route::get('/users/{id}', [UserController::class, 'show']);
    Route::put('/users/{id}', [UserController::class, 'update']);
    Route::delete('/users/{id}', [UserController::class, 'destroy']);
    
    // Profil routes ← PERBAIKI SEMUA YANG ADA "Prof ilController"
    Route::get('/profil', [ProfilController::class, 'index']);
    Route::get('/profil/{id}', [ProfilController::class, 'show']);
    Route::get('/profil/user/{userId}', [ProfilController::class, 'showByUserId']);
    Route::post('/profil', [ProfilController::class, 'store']);
    Route::put('/profil/{id}', [ProfilController::class, 'update']);
    Route::delete('/profil/{id}', [ProfilController::class, 'destroy']);
    
    // Jabatan routes
    Route::apiResource('jabatan', JabatanController::class);
    
    // Kegiatan routes
    Route::apiResource('kegiatans', KegiatanController::class);
    
    // Bukti Kegiatan routes
    Route::apiResource('bukti_kegiatans', BuktiKegiatanController::class);
    
    // Logout
    Route::post('/logout', function (Request $request) {
        $request->user()->currentAccessToken()->delete();
        return response()->json(['message' => 'Logged out successfully']);
    });
});