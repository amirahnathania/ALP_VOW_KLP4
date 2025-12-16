<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\User;
use App\Models\Kegiatan;
use App\Models\Profil;
use App\Models\BuktiKegiatan;
use App\Models\Jabatan;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Carbon\Carbon;

class DashboardController extends Controller
{
    /**
     * Display dashboard
     */
    public function index()
    {
        $stats = $this->getStatistics();
        $recentActivities = $this->getRecentActivities();
        $chartData = $this->getChartData();

        return view('admin.dashboard', compact('stats', 'recentActivities', 'chartData'));
    }

    /**
     * Get dashboard statistics
     */
    private function getStatistics(): array
    {
        return [
            'total_users' => User::count(),
            'total_kegiatan' => Kegiatan::count(),
            'total_profil' => Profil::count(),
            'total_bukti' => BuktiKegiatan::count(),
            'users_this_month' => User::whereMonth('created_at', Carbon::now()->month)->count(),
            'kegiatan_this_month' => Kegiatan::whereMonth('created_at', Carbon::now()->month)->count(),
            'active_kegiatan' => Kegiatan::where('tanggal_selesai', '>=', Carbon::now())->count(),
            'completed_kegiatan' => Kegiatan::where('tanggal_selesai', '<', Carbon::now())->count(),
        ];
    }

    /**
     * Get recent activities
     */
    private function getRecentActivities(): array
    {
        $recentUsers = User::latest()->take(5)->get()->map(function ($user) {
            return [
                'type' => 'user',
                'title' => 'User baru terdaftar',
                'description' => $user->nama_pengguna,
                'time' => $user->created_at,
                'icon' => 'user-plus',
            ];
        });

        $recentKegiatan = Kegiatan::latest()->take(5)->get()->map(function ($kegiatan) {
            return [
                'type' => 'kegiatan',
                'title' => 'Kegiatan baru',
                'description' => $kegiatan->jenis_kegiatan,
                'time' => $kegiatan->created_at,
                'icon' => 'calendar',
            ];
        });

        return collect()
            ->merge($recentUsers)
            ->merge($recentKegiatan)
            ->sortByDesc('time')
            ->take(10)
            ->values()
            ->toArray();
    }

    /**
     * Get chart data
     */
    private function getChartData(): array
    {
        $months = collect();
        for ($i = 5; $i >= 0; $i--) {
            $months->push(Carbon::now()->subMonths($i)->format('M'));
        }

        $usersByMonth = [];
        $kegiatanByMonth = [];

        for ($i = 5; $i >= 0; $i--) {
            $date = Carbon::now()->subMonths($i);
            $usersByMonth[] = User::whereYear('created_at', $date->year)
                ->whereMonth('created_at', $date->month)
                ->count();
            $kegiatanByMonth[] = Kegiatan::whereYear('created_at', $date->year)
                ->whereMonth('created_at', $date->month)
                ->count();
        }

        return [
            'labels' => $months->toArray(),
            'users' => $usersByMonth,
            'kegiatan' => $kegiatanByMonth,
        ];
    }

    /**
     * API endpoint for dashboard stats
     */
    public function stats()
    {
        return response()->json([
            'success' => true,
            'data' => $this->getStatistics(),
        ]);
    }
}
