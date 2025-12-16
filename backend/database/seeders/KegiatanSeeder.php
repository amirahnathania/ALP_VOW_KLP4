<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use App\Models\Kegiatan;
use App\Models\Profil;
use Carbon\Carbon;

class KegiatanSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        $profils = Profil::all();
        if ($profils->isEmpty()) {
            return;
        }

        $count = 0;
        foreach ($profils as $profil) {
            Kegiatan::create([
                'jenis_kegiatan' => 'Penanaman Padi',
                'id_profil' => $profil->id,
                'tanggal_mulai' => Carbon::now()->addDays($count)->format('Y-m-d'),
                'tanggal_selesai' => Carbon::now()->addDays($count + 1)->format('Y-m-d'),
                'waktu_mulai' => '08:00:00',
                'waktu_selesai' => '12:00:00',
                'jenis_pestisida' => 'Tidak ada',
                'target_penanaman' => 100 + ($count * 10),
                'keterangan' => 'Kegiatan seeding contoh untuk testing.'
            ]);

            $count++;
        }

        // Add one extra sample kegiatan for the first profil (if exists)
        if ($profils->first()) {
            $first = $profils->first();
            Kegiatan::create([
                'jenis_kegiatan' => 'Pemupukan',
                'id_profil' => $first->id,
                'tanggal_mulai' => Carbon::now()->addDays(7)->format('Y-m-d'),
                'tanggal_selesai' => Carbon::now()->addDays(7)->format('Y-m-d'),
                'waktu_mulai' => '07:00:00',
                'waktu_selesai' => '10:00:00',
                'jenis_pestisida' => 'N/A',
                'target_penanaman' => 50,
                'keterangan' => 'Pemupukan rutin.'
            ]);
        }
    }
}
