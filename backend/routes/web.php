<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\Admin\AuthController;
use App\Http\Controllers\Admin\DashboardController;
use App\Http\Controllers\Admin\UserController;
use App\Http\Controllers\Admin\KegiatanController;
use App\Http\Controllers\Admin\AdminController;

Route::get('/', function () {
    return view('admin/login');
});

// Admin Routes
Route::prefix('admin')->name('admin.')->group(function () {
    // Guest routes
    Route::middleware('admin.guest')->group(function () {
        Route::get('/login', [AuthController::class, 'showLoginForm'])->name('login');
        Route::post('/login', [AuthController::class, 'login'])->name('login.submit');
    });

    // Authenticated routes
    Route::middleware('admin.auth')->group(function () {
        Route::post('/logout', [AuthController::class, 'logout'])->name('logout');

        // Dashboard
        Route::get('/', [DashboardController::class, 'index'])->name('dashboard');
        Route::get('/dashboard', [DashboardController::class, 'index'])->name('dashboard.index');
        Route::get('/dashboard/stats', [DashboardController::class, 'stats'])->name('dashboard.stats');

        // Users
        Route::resource('users', UserController::class);
        Route::post('/users/bulk-destroy', [UserController::class, 'bulkDestroy'])->name('users.bulk-destroy');
        Route::get('/users-export', [UserController::class, 'export'])->name('users.export');

        // Kegiatan
        Route::resource('kegiatan', KegiatanController::class);
        Route::post('/kegiatan/bulk-destroy', [KegiatanController::class, 'bulkDestroy'])->name('kegiatan.bulk-destroy');
        Route::get('/kegiatan-export', [KegiatanController::class, 'export'])->name('kegiatan.export');

        // Admin management (superadmin only)
        Route::middleware('superadmin')->group(function () {
            Route::resource('admins', AdminController::class)->except(['create', 'edit']);
            Route::post('/admins/{admin}/toggle-status', [AdminController::class, 'toggleStatus'])->name('admins.toggle-status');
        });

        // Profile
        Route::get('/profile', [AdminController::class, 'showProfile'])->name('profile');
        Route::put('/profile', [AdminController::class, 'updateProfile'])->name('profile.update');
    });
});
