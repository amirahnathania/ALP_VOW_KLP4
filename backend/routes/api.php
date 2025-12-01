<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\UserController;
use App\Http\Controllers\JabatanController;
use App\Http\Controllers\ProfilController;

// Test route
Route::get('/test', function () {
    return response()->json(['message' => 'API is working!']);
});

// API Routes untuk User, Jabatan, Profil
Route::apiResource('users', UserController::class);
Route::apiResource('jabatan', JabatanController::class);
Route::apiResource('profil', ProfilController::class);