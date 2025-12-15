<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use App\Models\Admin;

class AdminSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        // Create Super Admin
        Admin::create([
            'name' => 'Super Admin',
            'email' => 'superadmin@belajartani.ac.id',
            'password' => 'superadmin',
            'role' => 'superadmin',
            'is_active' => true,
        ]);

        // Create Admin
        Admin::create([
            'name' => 'Admin',
            'email' => 'admin@belajartani.ac.id',
            'password' => 'admin',
            'role' => 'admin',
            'is_active' => true,
        ]);
    }
}
