<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\UserController;
use App\Http\Controllers\JabatanController;
use App\Http\Controllers\ProfilController;
use App\Http\Controllers\KegiatanController;
use App\Http\Controllers\BuktiKegiatanController;

// Test route
Route::get('/test', function () {
    return response()->json(['message' => 'API is working!']);
});

// ========== PUBLIC ROUTES (tanpa auth) ==========
Route::post('/login', [UserController::class, 'login']);
Route::post('/users', [UserController::class, 'store']); 

<<<<<<< HEAD
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

// Endpoint khusus untuk menampilkan gambar BLOB
Route::get('bukti_kegiatans/{id}/image', [BuktiKegiatanController::class, 'getImage']);
=======
// ========== PROTECTED ROUTES (dengan auth) ==========
Route::middleware('auth:sanctum')->group(function () {
    Route::post('/logout', [UserController::class, 'logout']);
    
    // CRUD Users lainnya (GET, PUT, DELETE)
    Route::get('/users', [UserController::class, 'index']);
    Route::get('/users/{id}', [UserController::class, 'show']);
    Route::put('/users/{id}', [UserController::class, 'update']);
    Route::patch('/users/{id}', [UserController::class, 'update']);
    Route::delete('/users/{id}', [UserController::class, 'destroy']);
    
    // API Resources lainnya
    Route::apiResource('jabatan', JabatanController::class);
    Route::apiResource('profil', ProfilController::class);
    Route::apiResource('kegiatans', KegiatanController::class);
    Route::apiResource('bukti_kegiatans', BuktiKegiatanController::class);
});
>>>>>>> b46c528d3d29d3e02b89606f702d3e03bc2eb3de
