<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use App\Models\BuktiKegiatan;
use App\Models\Kegiatan;
use Carbon\Carbon;

class BuktiKegiatanSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        $images = [
            'dirt.webp',
            'leaf.webp',
            'road.webp',
            'tomato.webp',
        ];

        $kegiatans = Kegiatan::all();
        if ($kegiatans->isEmpty()) {
            return;
        }

        foreach ($kegiatans as $kegiatan) {
            $count = rand(1, 3);
            for ($i = 0; $i < $count; $i++) {
                $file = $images[array_rand($images)];
                $nameOnly = pathinfo($file, PATHINFO_FILENAME);
                $ext = '.' . pathinfo($file, PATHINFO_EXTENSION);

                BuktiKegiatan::create([
                    'id_kegiatan' => $kegiatan->id,
                    'id_profil' => $kegiatan->id_profil ?? null,
                    'nama_foto' => $nameOnly,
                    'tipe_foto' => $ext,
                    'created_at' => Carbon::now()->subDays(rand(0, 10)),
                ]);
            }
        }
    }
}
