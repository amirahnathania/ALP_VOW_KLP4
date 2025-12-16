<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use App\Models\User;
use App\Models\Jabatan;
use App\Models\Profil;
use Carbon\Carbon;

class DatabaseSeeder extends Seeder
{
    /**
     * Seed the application's database.
     */
    public function run(): void
    {
        // Create Jabatan
        $jabatanKetua = Jabatan::create([
            'jabatan' => 'Ketua Gabungan Kelompok Tani',
            'awal_jabatan' => Carbon::now()->format('Y-m-d'),
            'akhir_jabatan' => Carbon::now()->addYears(2)->format('Y-m-d'),
        ]);

        $jabatanGapoktan = Jabatan::create([
            'jabatan' => 'Anggota Gapoktan',
            'awal_jabatan' => Carbon::now()->format('Y-m-d'),
            'akhir_jabatan' => Carbon::now()->addYears(4)->format('Y-m-d'),
        ]);

        // Create Users
        $userKetua = User::create([
            'nama_pengguna' => 'Ketua',
            'email' => 'ketua@ketua.ac.id',
            'password' => 'Password123',
        ]);

        $userGapoktan = User::create([
            'nama_pengguna' => 'Gapoktan',
            'email' => 'gapoktan@gapoktan.ac.id',
            'password' => 'Password123',
        ]);

        // Create Profil
        Profil::create([
            'id_user' => $userKetua->id,
            'id_jabatan' => $jabatanKetua->id,
        ]);

        Profil::create([
            'id_user' => $userGapoktan->id,
            'id_jabatan' => $jabatanGapoktan->id,
        ]);

        // Seed kegiatan related to created profils
        $this->call(\Database\Seeders\KegiatanSeeder::class);
        // Seed Admin users
        $this->call(AdminSeeder::class);
        // Seed bukti foto for existing kegiatan (use images in public/images)
        $this->call(BuktiKegiatanSeeder::class);
    }
}
