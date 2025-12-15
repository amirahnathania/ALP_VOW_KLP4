@extends('admin.layouts.app')

@section('title', 'Dashboard')

@section('conten    t')
<div class="space-y-6">
    <!-- Page Header --    >
    <div class="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-4">
            <div>
                <h1 class="text-2xl font-bold text-gray-900">Dashboard</h1>
                <p class="text-gray-500 mt-1">Selamat datang, {{ Auth::guard('admin')->user()->name }}!</p    >
        </di    v>
        <div class="flex items-center gap-3">
            <button onclick="refreshStats()" class="btn btn-secondary">
                    <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" s
t                           roke-width="2" d="M4 4v5h.582m15.356 2A8.001 8.001 0 004.582 9m0 0H9m11 11v-5h-.581m0 0a8.003 8.003 0 01-15.357-
                        2m15.357 2H15"></path>
                    </svg>
                Ref    resh
            </bu  <select class="form-input w-auto" id="date-range">
                    <option value="today">Hari Ini</option>
                    <option value="week">7 Hari Terakhir</option>
                    <option value="month" selected>30 Hari Terakhir</option>
                    <option value="year">Tahun Ini</option>
                </select>n>
</div> on>
                </sel    ect>
            </div>
    </div>

        <!-- Stats Cards -->
    <div class="grid grid-cols-1 sm:grid-cols-2 lg    :grid-cols-4 gap-6">
            <!-- Total Users -->
        <div c    lass="stats-card">
            <div class="flex items-center ju    stify-between">
                    <div>
                    <p class="text-sm text-gray-500 font-medium">To    tal Users</p>
                    <p class="text-2xl font-bold text-gray-900 mt-1">{{ number_format($stats['total_u    sers']) }}</p>
                    <p class="text-xs text-green-600 mt-2 flex items-cen    ter gap-1">
                        <svg class="w-3 h-3" fill="none" stroke="currentColor" viewBox="0 0     24 24">
                            <path stroke-linecap="round" st
r                                   oke-linejoin="round" stroke-width="2" d="M5 10l7-7m0 0l7 7m-7-    7v18"></path>
                            </svg>
                        +{{ $stats['users_this_m    onth'] }} bulan ini
                        </p    >
                </div>
                <div class="w-12 h-12 bg-[#d1d1d1] rounded-xl flex items-c    enter justify-center">
                    <svg class="w-6 h-6 text-[#0b1319]" fill="none" stroke="currentColor" v    iewBox="0 0 24 24">
                        <path stroke-linecap="ro
u                               nd" stroke-linejoin="round" stroke-width="2" d="M12 4.354a4 4 0 110 5.292M15 21H3v-1a6 6 0 0112 0v1zm0 0h6v-1a6 6
                            0 00-9-5.197M13 7a4 4 0 11-8     0 4 4 0 018 0z"></path    >
                        </svg>
                    </d    iv>
            </div>
            </div>

        <!-- Total Kegiata    n -->
        <div class="stats-card">
            <div class=    "flex items-center justify    -between">
                <div>
                    <p class="text-sm text-gray-5    00 font-medium">Total Kegiatan</p>
                    <p class="text-2xl font-bold text-gray-900 mt-1">{{ number_form    at($stats['total_kegiatan']) }}</p>
                    <p class="text-xs text-blue-60    0 mt-2 flex items-center gap-1">
                        <svg class="w-3 h-3" fill="none" stroke="curre    ntColor" viewBox="0 0 24 24">
                            <path stro
k                                   e-linecap="round" stroke-linejoin="round" stroke-width="2" d="    M5 10l7-7m0 0l7 7m-7-7v18"></pa    th>
                        </svg>
                        +{{ $s    tats['kegiatan_this_m    onth'] }} bulan ini
                        </p>
                </div>
                <div class="w-12 h-12 bg-blue-100 ro    unded-xl flex items-center justify-center">
                    <svg class="w-6 h-6 text-blue-600" fill="none" st    roke="currentColor" viewBox="0 0 24 24">
                        <pa
t                               h stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M8 7V3m8 4V3m-9 8h10M5
                             21h14a2 2 0 002-2V7a2 2 0 0    0-2-2H5a2 2 0 00-2 2v12    a2 2 0 002 2z"></pa    th>
                        </svg>
                </div>
                </div>
        </div>

            <!-- Active Kegiatan -->
        <div class="stats-card">
                <div class="flex     items-center justify-between">
                <div>
                    <p class    ="text-sm text-gray-500 font-medium">Kegiatan Aktif</p>
                    <p class="text-2xl font-bold text-gray-900     mt-1">{{ number_format($stats['active_kegiatan']) }}</p>
                    <p class="    text-xs text-green-600 mt-2 flex items-center gap-1">
                        <span class="w-    2 h-2 bg-green-500 rounded-full animate    -pulse"></span>
                            Sed    ang berlangsung
                    </p>
                </div>
                <div class="w-12 h    -12 bg-green-100 rounded-xl flex items-center justify-center">
                    <svg class="w-6 h-6 text-green-    600" fill="none" stroke="currentColor" viewBox="0 0 24 24">

                                               <path stroke-linecap="round" stroke-linejoin="round" stroke-wid    th="2" d="M9 12l2 2 4-4    m6 2a9 9 0 11-18 0     9 9 0 0118 0z">    </path>
                        </svg>
                    </div>
            </div>
            </div>

        <!-- Total Bukti -->
        <div clas    s="stats-card">
                <div class="flex items-center justify-between">
                <div>
                        <p class="text-sm text-gray-500 font-medium">Bukti Kegiatan</p>
                    <p class="text-2xl f    ont-bold text-gray-900 mt-1">{{ number_format($stats['total_bukti']) }}</p>
                        <p class="text-xs text-purple-600 mt-2 flex items-center gap-1">
                        <svg c    lass="w-3 h-3" fill="none" stroke="currentColor" viewBox="0 0 24 24">

                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 16l4.586-4.586a2 2 0 012.828 0L16 16m-2-2l1.586-1.586
                                a2 2 0 012.828 0L20 14m-6-6h.01M    6 20h12a2 2 0 002-2V6a2 2 0 00-    2-2H6a2 2 0 00-2 2v12a2 2 0 002 2z"></pat    h>
                            </svg>
                            Total foto terupload
                    </p>
                </div>
                    <div class="w-12 h-12 bg-purple-100 rounded-xl flex items-center justify-center">
                    <svg class=    "w-6 h-6 text-purple-600" fill="none" stroke="currentColor" viewBox="
0                                0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 16l4.586-4.586a2 2 0 012.828 0L16 16m-2-2l1.58
                            6-1.586a2 2 0 012.828 0L20 1    4m-6-6h.01M6 20h12a2 2     0 002-2V6a2 2 0 00-    2-2H6a2 2 0 00-    2 2v12a2 2     0 002 2z"></    path>
                        </svg>
                </div>
            </div>
            </div>
    </div>

        <!-- Charts Row -->
    <div class="grid gr    id-cols-1 lg:grid-cols-3 gap-6">
        <!-- Main Chart -->
        <div     class="lg:col-span-2 card">
            <div class="card-header flex     items-center justify-between">
                <h3 class="font-se    mibold text-gray-900">Overview</h3>
                <div class    ="flex items-center gap-4 text-sm">
                    <span class="flex items    -center gap-2">
                            <span class="    w-3 h-3 bg-[#0b1319] rounded-full"></span>
                            Users
                    </span>
                    <span class="flex     items-center gap-2">
                            <span c    lass="w-3 h-3 bg-bl    ue-500 rounded-full    "></span>
                        Kegia    tan
                    </span>
                    </div>
            </div>
            <div clas    s="card-body">
                    <d    iv class="chart-    container">
                        <canvas id="mainChart"></canvas    >
                </div>
            </d    iv>
        </div>

        <!-- Kegiatan Status -->
        <div cla    ss="card">
                <div class="card-header">
                    <h3 class="font-semibold text-gray-900">Status Kegi    atan</h3>
            </div>
            <div class="card-body">
                    <div class="fle    x justify-center mb-6">
                        <canvas id="statusChart" width="180" height="180"></canvas>
                    </div>
                <div class="space-y-3">
                        <div class="flex items-center justify-between">
                        <d    iv class="flex items-center gap-2">
                            <span cl    ass="w-3 h-3 bg-green-500 round    ed-full"></span>
                            <span class="text-sm text-gray-600">Aktif</span>
                            </div>
                            <span class="text-sm font-medium text-gray-900">{{ $st    ats['active_kegiatan'] }}</span>
                    </div>
                        <div class="flex items-center justify-between">
                            <div class="flex items-center gap-2">
                            <s    pan class="w-3 h-3 bg-gray-400     rounded-full"></span>
                            <span class="text-sm text-gray-600">Selesai</span>
                            </div>
                            <span cl    ass="text-s    m font-mediu    m text-gray-900">{{ $stats['completed_kegiata    n'] }}</span>
                    </div>
                <    /div>
            </div>
            </div>
    </div>

    <!-- Recent Activ    ity & Quick Actions -->
    <div class="grid grid-cols-1 lg:grid-cols-3 gap    -6">
        <!-- Recent Activity -->
        <div class="lg:col-span-2 card"    >
            <div class="card-header flex items-center justify-between">
                <h3 class=    "font-semibold text    -gray-900">Aktivitas Terbaru</h3>
                <a h    ref="#" class="text-sm text-teal-600 hover:text-teal-700         font-medium">Lihat semua</a>
            </div>
            <div class="divide-y divide-gray-100">

                                          @forelse($recentActivities as $activity)
                <div class="px-6 py-4 flex items-center gap-4 hover:bg-gray-50 transition-colors">
                    <div class="w-10 h-10         rou nded-full flex items-center justify-center flex-shrink-            0
                        {{ $activity['type'] === 'user' ? 'bg-tea
l                                       -100' : 'bg-blue-100' }}">
                                    @if($activity['type'] === 'user')
                        <svg cl
a                                           ss="w-5 h-5 text-teal-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">

                                                              <path stro            ke-linecap="round" stroke-linej        oin="round" stroke-width="2" d            ="M18 9v3m0 0v3m0-3h3m-3 0h-3m-2-5a4 4 0 11-8 0 4 4 0 018 0zM3 20a6
6                                        0 0112 0v1H3v-1z"></path>
                                    </svg>
                        @else
                        <sv
g                                            class="w-5 h-5 text-blue-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">

                                                                            <path stroke-li        necap="round" stroke-linejoin="        round" stroke-width="2" d="        M8 7V3m8 4V3m-9 8h10M5 21h14a2 2 0 002-2V7a2 2 0         00-2-2H5a2 2 0 00-2 2v12a2 2 0 002 2z"></path>
                        </svg>
                                @endif
                    </div>
                    <div class="flex-1 min-w-0">
                                <p class="te        xt-sm font-medium text-gray-900">{{ $activity['title'] }}</p>
                                <p class="text-sm text-gray-500 truncate">{{ $activity['description'] }}        </p>
                    </        div>
                        <span class="text-xs         text-gray-400 flex-shrink-0">
                        {{ \Carbon        \Carbon::parse($activity['time'])->diffForHumans() }}
                    </span>
                </d
                               iv>
                @        empty
                <div class="px-6 py-8 text-center text-gray-500">

                                    <svg class="w-12 h-12 mx-auto text-gray-300 mb-3" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                                d="M20 1        3V6a2 2 0 00-2-2H6a2 2 0 00        -2 2v7m16 0v5a2 2 0 01-2 2H6a2 2 0 01-2-        2v-5m16 0h-2.586a1 1 0     00-.707.293l-2.414 2.414a1 1     0 01-.707.293h-3.1    72a1 1 0 01-.707    -.293l-2.414-2.414A1 1 0 006.58    6 13H4"></path>
                        </svg>
                        Belum ada aktivitas
                </div>
                @endforelse
                </div>
            </div>

        <!-- Quick Actions -    ->
        <div class="card">
            <div class="car
                       d-header">
                <h3 class="font-semibold text-gray-900">Quick Actions</h3>
                </div>

                                 <div class="card-body space-y-3">
                <a href="{{ route('admin.users.create') }}" class="flex items    -center gap-3 p-3 rounded-lg hover:bg-gray-50 transition-colors group">
                    <div class="w-10 h-10     bg-teal-100 rounded-lg flex items-center justify-center group-hover:bg-teal-200 transition-color
                                   s">
                        <svg class="w-5 h-5 text-teal-600" fill="none" stroke="curren
                                tColor"     viewBox="0 0 24 24">
                                <path st    roke-linecap="round" strok    e-linejoin="round" stroke-width="2" d="M18 9v3m0 0v3m0-3h3m-3 0h-3m-2-5a4 4 0 11-8 0     4 4 0 018 0zM3 20a6 6 0 0112 0v1H3v-1z"></path>
                        </svg>
                        </div>
                    <    div>
                        <p class="text-sm font-medium te
                       xt-gray-900">Tambah User</p>
                        <p class="text-xs text-gray-500">Daf    tarkan user baru</p>

                                             </div>
                </a>

                <a href="{{ route('admin.kegiatan.create') }}" class    ="flex items-center gap-3 p-3 rounded-lg hover:bg-gray-50 transition-colors group">
                    <div clas    s="w-10 h-10 bg-blue-100 rounded-lg flex items-center justify-center group-hover:bg-blue-200 tran
                                   sition-colors">
                            <svg class="w-5 h-5 text-blue-    600" fill="none" stroke="cu    rrentColor" viewBox="0 0 2    4 24">
                            <path stroke-linecap="round" stroke-linejoin="round"     stroke-width="2" d="M12 6v6m0 0v6m0-6h6m-6 0H6"></path>
                            </svg>
                        </div>
                        <div>
                        <p class="text-sm fo
                       nt-medium text-gray-900">Tambah Kegiatan</p>
                        <p class="text-xs te    xt-gray-500">Buat kegiat
                           an baru</p>
                    </div>
                </a>

                <a href="{{ route('admin.users.export')     }}" class="flex items-center gap-3 p-3 rounded-lg hover:bg-gray-50 transition-colors group">

                        <div class="w-10 h-10 bg-green-100 rounded-lg flex items-center justify-center group-hover:bg-gre
                                   en-200 transition-colors">
                        <svg class="w-5 h-5 text    -green-600" fill="none" stroke=    "currentColor" viewBox="0 0     24 24">
                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="    M4 16v1a3 3 0 003 3h10a3 3 0 003-3v-1m-4-4l-4 4m0 0l-4-4m4 4V4"></path>
                            </svg>
                        </    div>
                     <div>
                        <p class=        "text-sm font-medium text-gray-900">Export Data</p>

                                             <p class="text-xs text-gray-500">Download laporan</p>
                            </div>

                                  </a>

                @if(Auth::guard('admin')->user()->isSuperAdmin())
                <a href="{{ route('admin.adm        ins.index') }}" class="flex items-center gap-3 p-3 rounded-lg hover:bg-gray-50 transition-colo
                                   rs group">
                            <div class="w-10 h-10 bg-purple-100 rounded-lg flex items-center justify-center group-h
                                       over:bg-purple-200 transition-colors">
                        <svg class="w-5 h-5 text-purple-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                            <path strok
                                    e-lineca        p="round" stroke-linejoin="roun        d" stroke-width="2" d="M9 1        2l2 2 4-4m5.618-4.016A11.9        55 11.955 0 0112 2.944a11.955 11.955 0 01-8.618 3.04A12.02 12.02 0 003 9c0 5.591 3.824         10.29 9 11.622 5.176-1.332 9-6.03 9-11.622 0-1.042-.133-2.052-.382-3.016z"></path>
                        <        /svg>
                        </div>
                        <div>
                                <p     class="text-sm font-medium text-gray-    900">Kelo    la Admin</p>
                            <p class="text-xs text-gray-500">M    anage admin accoun    ts</p>
                    </div>
                </a>
                @    endif
            </div>
        </div>
        </div>
</div>
    @endsection

@push('scripts')
<scri    pt>
    // Chart data {f    nst chartData = @json($chartData);

    // Main Chart
    const mainCtx = do    cument.getElementById('mainChart').getContex    t('2d');
    new Chart(mainCtx, {
        type: 'line',
            data: {
            labels:     chartData.labels,
            dat    asets: [
                {
                        label: 'Users',
                        data: chartData.users,
                        bo    rderColor: '#0d948    8',
                    backgroundColo    r: 'rgba(13, 148, 136, 0.1)',
                        fill: true,
                    tensio    n: 0.4,
                    borderWidth: 2,
                        pointRadius: 4,
                        pointHoverRadius: 6,
                    },
                {
                        label: 'Kegiatan',
                    data: chartData.keg    iatan,
                        bord    erColor: '#    3b82f6',
                        backgroundColor: 'r    gba(59, 130, 246, 0.1)',
                        fill: true,
                        tension: 0    .4,
                    borderWidt    h: 2,
                        pointR    adius: 4,
                        pointHoverRa    dius: 6,
                }
            ]
        },
        opt    ions: {
            r    esponsive: true,
                maintainAs    pectRatio: false,
            plugins:     {
                legend:     {
                    display: false
                    }
                },
                scales: {
                    x    : {
                    grid:     {
                        display: false
                    }
                    },
                y: {
                    begi    nAtZero: true,
                        grid: {
                            color: '#f3f4f    6'
                    }
                }
            }
        }
    });

    // Sta    tus Chart (Doughnut)
    const statusCtx = document.getE    lementById('statusChart').getCon    text('2d');
    new Chart(sta    tusCtx, {
            type: '    doughnut',
            data: {
            labels:     ['Aktif', 'Selesai'],
            datas    ets: [{
                    data: [{{ $stats['active    _kegiatan'] }}, {{ $stats['complete    d_kegiatan'] }}],
                    backgro    undColor:     ['#10b981', '#9ca3af    '],
                borderWidth: 0,
                    cutout: '75%'
            }]
        },
       'options: {
         '  respon    sive: true,
            maintainAspectRatio: false,
                plugins: {
                legend: {
                        display: false
                }
                }
        }
    });

        // Refresh stats
    async function refreshStats() {
        t    ry {
                const response = await fetchApi('{{ route("admin.dashboard.stats") }}');
            showToast('Data berhasil diperbarui', 'success');
            // You can update the stats here if needed
            setTimeout(() => location.reload(), 500);
        } catch (error) {
            showToast('Gagal memperbarui data', 'error');
        }
    }
</script>
@endpush
