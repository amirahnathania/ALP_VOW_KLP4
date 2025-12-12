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