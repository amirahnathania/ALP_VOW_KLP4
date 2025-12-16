@extends('admin.layouts.app')

@section('title', 'Kegiatan')

@section('breadcrumb')
    <span class="text-gray-700 font-medium">Kegiatan</span>
@endsection

@section('content')
    <div class="space-y-6">
        <!-- Page Header -->
        <div class="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-4">
            <div>
                <h1 class="text-2xl font-bold text-gray-900">Kegiatan</h1>
                <p class="text-gray-500 mt-1">Kelola data kegiatan pertanian</p>
            </div>
            <div class="flex items-center gap-3">
                <a href="{{ route('admin.kegiatan.export') }}" class="btn btn-secondary">
                    <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                            d="M4 16v1a3 3 0 003 3h10a3 3 0 003-3v-1m-4-4l-4 4m0 0l-4-4m4 4V4"></path>
                    </svg>
                    Export
                </a>
                <button onclick="showCreateModal()" class="btn btn-primary">
                    <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                            d="M12 6v6m0 0v6m0-6h6m-6 0H6"></path>
                    </svg>
                    Tambah Kegiatan
                </button>
            </div>
        </div>

        <!-- Filters -->
        <div class="card">
            <div class="card-body">
                <form id="filter-form" class="space-y-3">
                    <div class="flex flex-col sm:flex-row gap-3">
                        <input type="text" name="search" value="{{ request('search') }}"
                            placeholder="Cari jenis kegiatan..." class="form-input w-full sm:min-w-[300px] sm:flex-1">

                        <select name="jenis" class="form-input w-full sm:w-auto">
                            <option value="">Semua Jenis</option>
                            @foreach ($jenisKegiatans as $jenis)
                                <option value="{{ $jenis }}" {{ request('jenis') == $jenis ? 'selected' : '' }}>
                                    {{ $jenis }}
                                </option>
                            @endforeach
                        </select>

                        <select name="status" class="form-input w-full sm:w-auto">
                            <option value="">Semua Status</option>
                            <option value="active" {{ request('status') == 'active' ? 'selected' : '' }}>Aktif</option>
                            <option value="completed" {{ request('status') == 'completed' ? 'selected' : '' }}>Selesai</option>
                        </select>

                        <div class="relative w-full sm:w-auto">
                            <input type="date" name="date_from" value="{{ request('date_from') }}"
                                class="form-input w-full peer">
                            <label class="absolute left-3 -top-2 bg-white px-1 text-xs text-gray-600">Mulai</label>
                        </div>

                        <div class="relative w-full sm:w-auto">
                            <input type="date" name="date_to" value="{{ request('date_to') }}"
                                class="form-input w-full peer">
                            <label class="absolute left-3 -top-2 bg-white px-1 text-xs text-gray-600">Akhir</label>
                        </div>

                        <div class="flex gap-2 sm:gap-3">
                            <button type="submit" class="btn btn-primary flex-1 sm:flex-initial whitespace-nowrap">Filter</button>
                            <a href="{{ route('admin.kegiatan.index') }}" class="btn btn-secondary flex-1 sm:flex-initial whitespace-nowrap">Reset</a>
                        </div>
                    </input>
                </form>
            </div>
        </div>

        <!-- Bulk Actions -->
        <div id="bulk-actions" class="hidden items-center gap-4 p-4 bg-teal-50 rounded-lg border border-teal-200">
            <span class="text-sm text-teal-800"><span id="selected-count">0</span> item dipilih</span>
            <button onclick="bulkDelete()" class="btn btn-danger btn-sm">
                <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                        d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16">
                    </path>
                </svg>
                Hapus Terpilih
            </button>
        </div>

        <!-- Table -->
        <div class="card" id="kegiatan-card">
            <!-- Loading Skeleton (only shows if there's lag) -->
            <div id="loading-skeleton" class="hidden">
                <x-skeleton type="table" :rows="5" />
            </div>

            <!-- Desktop Table View -->
            <div class="table-container hidden md:block">
                <table class="w-full">
                    <thead class="bg-gray-50">
                        <tr>
                            <th class="px-4 py-3 text-left">
                                <input type="checkbox" id="select-all" class="checkbox" onchange="toggleSelectAll()">
                            </th>
                            <th class="px-4 py-3 text-left text-xs font-semibold text-gray-600 uppercase tracking-wider">
                                Kegiatan</th>
                            <th class="px-4 py-3 text-left text-xs font-semibold text-gray-600 uppercase tracking-wider">
                                Tanggal</th>
                            <th class="px-4 py-3 text-left text-xs font-semibold text-gray-600 uppercase tracking-wider">
                                Waktu</th>
                            <th class="px-4 py-3 text-left text-xs font-semibold text-gray-600 uppercase tracking-wider">
                                Target</th>
                            <th class="px-4 py-3 text-left text-xs font-semibold text-gray-600 uppercase tracking-wider">
                                Status</th>
                            <th class="px-4 py-3 text-right text-xs font-semibold text-gray-600 uppercase tracking-wider">
                                Aksi</th>
                        </tr>
                    </thead>
                    <tbody class="divide-y divide-gray-200">
                        @forelse($kegiatans as $kegiatan)
                            @php
                                $isActive = \Carbon\Carbon::parse($kegiatan->tanggal_selesai)->isFuture();
                            @endphp
                            <tr class="hover:bg-gray-50 transition-colors" data-id="{{ $kegiatan->id }}">
                                <td class="px-4 py-3">
                                    <input type="checkbox" class="checkbox row-checkbox" value="{{ $kegiatan->id }}"
                                        onchange="updateBulkActions()">
                                </td>
                                <td class="px-4 py-3">
                                    <div class="flex items-center gap-3">
                                        <div class="w-10 h-10 rounded-lg bg-blue-100 flex items-center justify-center">
                                            <svg class="w-5 h-5 text-blue-600" fill="none" stroke="currentColor"
                                                viewBox="0 0 24 24">
                                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                                                    d="M8 7V3m8 4V3m-9 8h10M5 21h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v12a2 2 0 002 2z">
                                                </path>
                                            </svg>
                                        </div>
                                        <div>
                                            <p class="font-medium text-gray-900">{{ $kegiatan->jenis_kegiatan }}</p>
                                            <p class="text-xs text-gray-500">#{{ $kegiatan->id }}</p>
                                        </div>
                                    </div>
                                </td>
                                <td class="px-4 py-3">
                                    <div class="text-sm">
                                        <p class="text-gray-900">
                                            {{ \Carbon\Carbon::parse($kegiatan->tanggal_mulai)->format('d M Y') }}</p>
                                        <p class="text-gray-500">s/d
                                            {{ \Carbon\Carbon::parse($kegiatan->tanggal_selesai)->format('d M Y') }}</p>
                                    </div>
                                </td>
                                <td class="px-4 py-3">
                                    <span class="text-sm text-gray-600">
                                        {{ \Carbon\Carbon::parse($kegiatan->waktu_mulai)->format('H:i') }} -
                                        {{ \Carbon\Carbon::parse($kegiatan->waktu_selesai)->format('H:i') }}
                                    </span>
                                </td>
                                <td class="px-4 py-3">
                                    <span
                                        class="text-sm font-medium text-gray-900">{{ number_format($kegiatan->target_penanaman) }}</span>
                                </td>
                                <td class="px-4 py-3">
                                    <span class="badge {{ $isActive ? 'badge-success' : 'badge-secondary' }}">
                                        {{ $isActive ? 'Aktif' : 'Selesai' }}
                                    </span>
                                </td>
                                <td class="px-4 py-3">
                                    <div class="flex items-center justify-end gap-2">
                                        <button onclick="showKegiatan({{ $kegiatan->id }})"
                                            class="btn-icon text-gray-400 hover:text-blue-600 hover:bg-blue-50"
                                            title="Lihat">
                                            <svg class="w-4 h-4" fill="none" stroke="currentColor"
                                                viewBox="0 0 24 24">
                                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                                                    d="M15 12a3 3 0 11-6 0 3 3 0 016 0z"></path>
                                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                                                    d="M2.458 12C3.732 7.943 7.523 5 12 5c4.478 0 8.268 2.943 9.542 7-1.274 4.057-5.064 7-9.542 7-4.477 0-8.268-2.943-9.542-7z">
                                                </path>
                                            </svg>
                                        </button>
                                        <button onclick="showEditModal({{ $kegiatan->id }})"
                                            class="btn-icon text-gray-400 hover:text-teal-600 hover:bg-teal-50"
                                            title="Edit">
                                            <svg class="w-4 h-4" fill="none" stroke="currentColor"
                                                viewBox="0 0 24 24">
                                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                                                    d="M11 5H6a2 2 0 00-2 2v11a2 2 0 002 2h11a2 2 0 002-2v-5m-1.414-9.414a2 2 0 112.828 2.828L11.828 15H9v-2.828l8.586-8.586z">
                                                </path>
                                            </svg>
                                        </button>
                                        <button onclick="deleteKegiatan({{ $kegiatan->id }})"
                                            class="btn-icon text-gray-400 hover:text-red-600 hover:bg-red-50"
                                            title="Hapus">
                                            <svg class="w-4 h-4" fill="none" stroke="currentColor"
                                                viewBox="0 0 24 24">
                                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                                                    d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16">
                                                </path>
                                            </svg>
                                        </button>
                                    </div>
                                </td>
                            </tr>
                        @empty
                            <tr>
                                <td colspan="7" class="px-4 py-8 text-center text-gray-500">
                                    <svg class="w-12 h-12 mx-auto text-gray-300 mb-3" fill="none"
                                        stroke="currentColor" viewBox="0 0 24 24">
                                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                                            d="M8 7V3m8 4V3m-9 8h10M5 21h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v12a2 2 0 002 2z">
                                        </path>
                                    </svg>
                                    Tidak ada data kegiatan
                                </td>
                            </tr>
                        @endforelse
                    </tbody>
                </table>
            </div>

            <!-- Mobile Card View -->
            <div class="md:hidden space-y-3">
                @forelse($kegiatans as $kegiatan)
                    @php $isActiveMobile = \Carbon\Carbon::parse($kegiatan->tanggal_selesai)->isFuture(); @endphp
                    <div class="bg-white rounded-xl shadow-sm hover:shadow-md transition-all duration-200 p-5 border border-gray-100" data-id="{{ $kegiatan->id }}">
                        <div class="flex items-start gap-3 mb-4">
                            <input type="checkbox" class="checkbox row-checkbox mt-1" value="{{ $kegiatan->id }}"
                                onchange="updateBulkActions()">
                            <div class="flex-1 min-w-0">
                                <h3 class="font-semibold text-gray-900 text-base">{{ $kegiatan->jenis_kegiatan }}</h3>
                                <p class="text-sm text-gray-500">#{{ $kegiatan->id }}</p>
                            </div>
                            <span class="badge flex-shrink-0 {{ $isActiveMobile ? 'badge-success' : 'badge-secondary' }}">
                                {{ $isActiveMobile ? 'Aktif' : 'Selesai' }}
                            </span>
                        </div>

                        <div class="space-y-3 text-sm bg-gray-50 rounded-lg p-3">
                            <div class="flex items-center gap-3">
                                <svg class="w-4 h-4 text-[#386158] flex-shrink-0" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                                        d="M7 7h.01M7 3h5c.512 0 1.024.195 1.414.586l7 7a2 2 0 010 2.828l-7 7a2 2 0 01-2.828 0l-7-7A1.994 1.994 0 013 12V7a4 4 0 014-4z"></path>
                                </svg>
                                <div>
                                    <p class="text-sm text-gray-500">Jenis Kegiatan</p>
                                    <p class="text-gray-700 font-medium truncate">{{ $kegiatan->jenis_kegiatan }}</p>
                                </div>
                            </div>

                            <div class="flex items-center gap-3">
                                <svg class="w-4 h-4 text-[#386158] flex-shrink-0" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                                        d="M17 20h5v-2a3 3 0 00-5.356-1.857M17 20H7m10 0v-2c0-.656-.126-1.283-.356-1.857M7 20H2v-2a3 3 0 015.356-1.857M7 20v-2c0-.656.126-1.283.356-1.857m0 0a5.002 5.002 0 019.288 0M15 7a3 3 0 11-6 0 3 3 0 016 0zm6 3a2 2 0 11-4 0 2 2 0 014 0zM7 10a2 2 0 11-4 0 2 2 0 014 0z"></path>
                                </svg>
                                <div>
                                    <p class="text-sm text-gray-500">Profil / Kelompok</p>
                                    <p class="text-gray-700">{{ $kegiatan->profil->nama_kelompok ?? $kegiatan->profil->user->nama_pengguna ?? '-' }}</p>
                                </div>
                            </div>

                            <div class="flex items-center gap-3">
                                <svg class="w-4 h-4 text-[#386158] flex-shrink-0" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                                        d="M8 7V3m8 4V3m-9 8h10M5 21h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v12a2 2 0 002 2z"></path>
                                </svg>
                                <div>
                                    <p class="text-sm text-gray-500">Tanggal</p>
                                    <p class="text-gray-700">{{ \Carbon\Carbon::parse($kegiatan->tanggal_mulai)->format('d M Y') }} - {{ \Carbon\Carbon::parse($kegiatan->tanggal_selesai)->format('d M Y') }}</p>
                                </div>
                            </div>

                            @if($kegiatan->keterangan)
                            <div class="flex items-start gap-3">
                                <svg class="w-4 h-4 text-[#386158] flex-shrink-0 mt-0.5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                                        d="M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z"></path>
                                </svg>
                                <div>
                                    <p class="text-sm text-gray-500">Keterangan</p>
                                    <p class="text-gray-700 line-clamp-2">{{ $kegiatan->keterangan }}</p>
                                </div>
                            </div>
                            @endif
                        </div>

                        <div class="flex items-center gap-2 mt-4 pt-4 border-t border-gray-200">
                            <button onclick="showKegiatan({{ $kegiatan->id }})"
                                class="flex-1 inline-flex items-center justify-center gap-2 px-4 py-2.5 bg-white border border-gray-300 rounded-lg text-gray-700 font-medium hover:bg-gray-50 hover:border-[#386158] hover:text-[#386158] active:scale-95 transition-all duration-200 touch-manipulation"
                                title="Lihat">
                                <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                                        d="M15 12a3 3 0 11-6 0 3 3 0 016 0z"></path>
                                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                                        d="M2.458 12C3.732 7.943 7.523 5 12 5c4.478 0 8.268 2.943 9.542 7-1.274 4.057-5.064 7-9.542 7-4.477 0-8.268-2.943-9.542-7z"></path>
                                </svg>
                                <span>Lihat</span>
                            </button>
                            <button onclick="showEditModal({{ $kegiatan->id }})"
                                class="flex-1 inline-flex items-center justify-center gap-2 px-4 py-2.5 bg-[#386158] text-white rounded-lg font-medium hover:bg-[#2d4a43] active:scale-95 transition-all duration-200 shadow-sm touch-manipulation"
                                title="Edit">
                                <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                                        d="M11 5H6a2 2 0 00-2 2v11a2 2 0 002 2h11a2 2 0 002-2v-5m-1.414-9.414a2 2 0 112.828 2.828L11.828 15H9v-2.828l8.586-8.586z"></path>
                                </svg>
                                <span>Edit</span>
                            </button>
                            <button onclick="deleteKegiatan({{ $kegiatan->id }})"
                                class="p-2.5 bg-white border border-gray-300 rounded-lg text-red-600 hover:bg-red-50 hover:border-red-300 active:scale-95 transition-all duration-200 touch-manipulation"
                                title="Hapus">
                                <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                                        d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16"></path>
                                </svg>
                            </button>
                        </div>
                    </div>
                @empty
                    <div class="card text-center py-8">
                        <svg class="w-12 h-12 mx-auto text-gray-300 mb-3" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                                d="M9 5H7a2 2 0 00-2 2v12a2 2 0 002 2h10a2 2 0 002-2V7a2 2 0 00-2-2h-2M9 5a2 2 0 002 2h2a2 2 0 002-2M9 5a2 2 0 012-2h2a2 2 0 012 2"></path>
                        </svg>
                        <p class="text-gray-500">Tidak ada data kegiatan</p>
                    </div>
                @endforelse
            </div>

            <!-- Pagination -->
            @if ($kegiatans->hasPages())
                <div class="px-4 py-3 border-t border-gray-200">
                    {{ $kegiatans->links() }}
                </div>
            @endif
        </div>
    </div>

    <!-- Profil Options for JS -->
    <script>
        const profilOptions = @json($profils);
    </script>
@endsection

@push('scripts')
    <script>
        // Smart skeleton loading - only show if content takes time to render
        (function() {
            const skeleton = document.getElementById('loading-skeleton');
            const card = document.getElementById('kegiatan-card');
            let loadingTimeout;
            let isContentLoaded = false;

            // Show skeleton only if content takes more than 200ms to load
            loadingTimeout = setTimeout(function() {
                if (!isContentLoaded && skeleton && card) {
                    skeleton.classList.remove('hidden');
                    // Hide all children except skeleton using inline styles
                    Array.from(card.children).forEach(child => {
                        if (child.id !== 'loading-skeleton') {
                            child.style.display = 'none';
                        }
                    });
                }
            }, 200);

            // Mark content as loaded when DOM is ready
            if (document.readyState === 'loading') {
                document.addEventListener('DOMContentLoaded', function() {
                    isContentLoaded = true;
                    clearTimeout(loadingTimeout);
                    if (skeleton) skeleton.classList.add('hidden');
                    if (card) {
                        Array.from(card.children).forEach(child => {
                            if (child.id !== 'loading-skeleton') {
                                child.style.display = '';
                            }
                        });
                    }
                });
            } else {
                // DOM already loaded
                isContentLoaded = true;
                clearTimeout(loadingTimeout);
            }
        })();

        // Toggle select all
        function toggleSelectAll() {
            const selectAll = document.getElementById('select-all');
            const checkboxes = document.querySelectorAll('.row-checkbox');
            checkboxes.forEach(cb => cb.checked = selectAll.checked);
            updateBulkActions();
        }

        // Update bulk actions visibility
        function updateBulkActions() {
            const checked = document.querySelectorAll('.row-checkbox:checked');
            const bulkActions = document.getElementById('bulk-actions');
            const selectedCount = document.getElementById('selected-count');
            const selectAll = document.getElementById('select-all');
            const allCheckboxes = document.querySelectorAll('.row-checkbox');

            if (checked.length > 0) {
                bulkActions.classList.remove('hidden');
                bulkActions.classList.add('flex');
                // Only divide by 2 if all checkboxes are checked (select-all was used)
                const count = (selectAll && selectAll.checked && checked.length === allCheckboxes.length)
                    ? checked.length / 2
                    : checked.length;
                selectedCount.textContent = count;
            } else {
                bulkActions.classList.add('hidden');
                bulkActions.classList.remove('flex');
            }
        }

        // Get selected IDs
        function getSelectedIds() {
            return Array.from(document.querySelectorAll('.row-checkbox:checked')).map(cb => cb.value);
        }

        // Get form content
        function getFormContent(data = {}) {
            return `
            <form id="kegiatan-form" class="space-y-4">
                <div>
                    <label class="form-label">Jenis Kegiatan <span class="text-red-500">*</span></label>
                    <input type="text" name="jenis_kegiatan" value="${data.jenis_kegiatan || ''}" class="form-input" required>
                </div>
                <div class="grid grid-cols-2 gap-4">
                    <div>
                        <label class="form-label">Tanggal Mulai <span class="text-red-500">*</span></label>
                        <input type="date" name="tanggal_mulai" value="${data.tanggal_mulai || ''}" class="form-input" required>
                    </div>
                    <div>
                        <label class="form-label">Tanggal Selesai <span class="text-red-500">*</span></label>
                        <input type="date" name="tanggal_selesai" value="${data.tanggal_selesai || ''}" class="form-input" required>
                    </div>
                </div>
                <div class="grid grid-cols-2 gap-4">
                    <div>
                        <label class="form-label">Waktu Mulai <span class="text-red-500">*</span></label>
                        <input type="time" name="waktu_mulai" value="${data.waktu_mulai?.substring(0,5) || ''}" class="form-input" required>
                    </div>
                    <div>
                        <label class="form-label">Waktu Selesai <span class="text-red-500">*</span></label>
                        <input type="time" name="waktu_selesai" value="${data.waktu_selesai?.substring(0,5) || ''}" class="form-input" required>
                    </div>
                </div>
                <div>
                    <label class="form-label">Jenis Pestisida</label>
                    <input type="text" name="jenis_pestisida" value="${data.jenis_pestisida || ''}" class="form-input">
                </div>
                <div>
                    <label class="form-label">Target Penanaman <span class="text-red-500">*</span></label>
                    <input type="number" name="target_penanaman" value="${data.target_penanaman || ''}" class="form-input" required min="0">
                </div>
                <div>
                    <label class="form-label">Profil</label>
                    <select name="id_profil" class="form-input">
                        <option value="">Pilih Profil (Opsional)</option>
                        ${profilOptions.map(p => `<option value="${p.id}" ${data.id_profil == p.id ? 'selected' : ''}>${p.user?.nama_pengguna || 'Profil #' + p.id}</option>`).join('')}
                    </select>
                </div>
                <div>
                    <label class="form-label">Keterangan</label>
                    <textarea name="keterangan" rows="3" class="form-input">${data.keterangan || ''}</textarea>
                </div>
            </form>
        `;
        }

        // Show create modal
        function showCreateModal() {
            showModal({
                title: 'Tambah Kegiatan Baru',
                size: 'lg',
                content: getFormContent(),
                confirmText: 'Simpan',
                onConfirm: createKegiatan
            });
        }

        // Create kegiatan
        async function createKegiatan() {
            const form = document.getElementById('kegiatan-form');
            const formData = new FormData(form);
            const data = Object.fromEntries(formData);

            try {
                const response = await fetchApi('{{ route('admin.kegiatan.store') }}', {
                    method: 'POST',
                    body: JSON.stringify(data)
                });

                showToast(response.message, 'success');
                closeModal();
                setTimeout(() => location.reload(), 500);
            } catch (error) {
                showToast(error.message, 'error');
            }
        }

        // Show kegiatan detail
        async function showKegiatan(id) {
            try {
                const response = await fetchApi(`/admin/kegiatan/${id}`);
                const kegiatan = response.data;
                const isActive = new Date(kegiatan.tanggal_selesai) > new Date();

                showModal({
                    title: 'Detail Kegiatan',
                    size: 'lg',
                    content: `
                    <div class="space-y-4">
                        <div class="flex items-center justify-between">
                            <h3 class="text-lg font-semibold text-gray-900">${kegiatan.jenis_kegiatan}</h3>
                            <span class="badge ${isActive ? 'badge-success' : 'badge-secondary'}">${isActive ? 'Aktif' : 'Selesai'}</span>
                        </div>
                        <div class="grid grid-cols-2 gap-4 pt-4 border-t">
                            <div>
                                <p class="text-sm text-gray-500">ID</p>
                                <p class="font-medium">#${kegiatan.id}</p>
                            </div>
                            <div>
                                <p class="text-sm text-gray-500">Target Penanaman</p>
                                <p class="font-medium">${kegiatan.target_penanaman.toLocaleString()}</p>
                            </div>
                            <div>
                                <p class="text-sm text-gray-500">Tanggal</p>
                                <p class="font-medium">${new Date(kegiatan.tanggal_mulai).toLocaleDateString('id-ID')} - ${new Date(kegiatan.tanggal_selesai).toLocaleDateString('id-ID')}</p>
                            </div>
                            <div>
                                <p class="text-sm text-gray-500">Waktu</p>
                                <p class="font-medium">${kegiatan.waktu_mulai?.substring(0,5) || '-'} - ${kegiatan.waktu_selesai?.substring(0,5) || '-'}</p>
                            </div>
                            <div>
                                <p class="text-sm text-gray-500">Jenis Pestisida</p>
                                <p class="font-medium">${kegiatan.jenis_pestisida || '-'}</p>
                            </div>
                            <div>
                                <p class="text-sm text-gray-500">Profil</p>
                                <p class="font-medium">${kegiatan.profil?.user?.nama_pengguna || '-'}</p>
                            </div>
                        </div>
                        ${kegiatan.keterangan ? `
                                <div class="pt-4 border-t">
                                    <p class="text-sm text-gray-500 mb-2">Keterangan</p>
                                    <p class="text-gray-700">${kegiatan.keterangan}</p>
                                </div>
                                ` : ''}
                    </div>
                `,
                    showFooter: false
                });
            } catch (error) {
                showToast(error.message, 'error');
            }
        }

        // Show edit modal
        async function showEditModal(id) {
            try {
                const response = await fetchApi(`/admin/kegiatan/${id}`);
                const kegiatan = response.data;

                showModal({
                    title: 'Edit Kegiatan',
                    size: 'lg',
                    content: getFormContent(kegiatan),
                    confirmText: 'Update',
                    onConfirm: () => updateKegiatan(id)
                });
            } catch (error) {
                showToast(error.message, 'error');
            }
        }

        // Update kegiatan
        async function updateKegiatan(id) {
            const form = document.getElementById('kegiatan-form');
            const formData = new FormData(form);
            const data = Object.fromEntries(formData);
            data._method = 'PUT';

            try {
                const response = await fetchApi(`/admin/kegiatan/${id}`, {
                    method: 'POST',
                    body: JSON.stringify(data)
                });

                showToast(response.message, 'success');
                closeModal();
                setTimeout(() => location.reload(), 500);
            } catch (error) {
                showToast(error.message, 'error');
            }
        }

        // Delete kegiatan
        function deleteKegiatan(id) {
            confirmDialog('Apakah Anda yakin ingin menghapus kegiatan ini?', async () => {
                try {
                    const response = await fetchApi(`/admin/kegiatan/${id}`, {
                        method: 'POST',
                        body: JSON.stringify({ _method: 'DELETE' })
                    });

                    showToast(response.message, 'success');
                    setTimeout(() => location.reload(), 500);
                } catch (error) {
                    showToast(error.message, 'error');
                }
            });
        }

        // Bulk delete
        function bulkDelete() {
            const ids = getSelectedIds();
            confirmDialog(`Apakah Anda yakin ingin menghapus ${ids.length} kegiatan?`, async () => {
                try {
                    const response = await fetchApi('{{ route('admin.kegiatan.bulk-destroy') }}', {
                        method: 'POST',
                        body: JSON.stringify({
                            ids
                        })
                    });

                    showToast(response.message, 'success');
                    setTimeout(() => location.reload(), 500);
                } catch (error) {
                    showToast(error.message, 'error');
                }
            });
        }

        // Auto-trigger modal if action parameter is present
        document.addEventListener('DOMContentLoaded', function() {
            const urlParams = new URLSearchParams(window.location.search);
            const action = urlParams.get('action');

            if (action === 'create') {
                showCreateModal();
            }
        });
    </script>
@endpush
