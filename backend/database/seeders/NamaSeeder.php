<?php

namespace Database\Seeders;

use Illuminate\Database\Console\Seeds\WithoutModelEvents;
use Illuminate\Database\Seeder;
use App\Models\User;
use Illuminate\Support\Facades\Hash;

class NamaSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        // User 1: Ketua
        User::create([
            'Nama_Pengguna' => 'Ketua',
            'email' => 'nama@ketua.ac.id',
            'password' => '12345678',
            'role' => 'ketua',
        ]);

        // User 2: Gapoktan
        User::create([
            'Nama_Pengguna' => 'Gapoktan',
            'email' => 'nama@gapoktan.ac.id',
            'password' => '12345678',
            'role' => 'gapoktan',
        ]);

        // User 3: Abyan
        User::create([
            'Nama_Pengguna' => 'Abyan',
            'email' => 'mabyan01@gapoktan.ac.id',
            'password' => 'Abyan69060',
            'role' => 'gapoktan',
        ]);
    }
}
