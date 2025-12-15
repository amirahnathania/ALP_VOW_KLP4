@extends('admin.layouts.app')

@section('title', 'Users')

@section('breadcrumb')
    <span class="text-gray-700 font-medium">Users</span>
@endsection

@section('content')
    <div class="space-y-6">
        <!-- Page Header -->
        <div class="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-4">
            <div>
                <h1 class="text-2xl font-bold text-gray-900">Users</h1>
                <p class="text-gray-500 mt-1">Kelola data pengguna aplikasi</p>
            </div>
            <div class="flex items-center gap-3">
                <a href="{{ route('admin.users.export') }}" class="btn btn-secondary">
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
                    Tambah User
                </button>
            </div>
        </div>

        <!-- Filters -->
        <div class="card">
            <div class="card-body">
                <form id="filter-form" class="flex flex-col md:flex-row gap-4">
                    <div class="flex-1">
                        <div class="relative">
                            <input type="text" name="search" value="{{ request('search') }}"
                                placeholder="Cari nama atau email..." class="form-input pl-10">
                            {{-- <svg class="w-5 h-5 absolute left-3 top-1/2 -translate-y-1/2 text-gray-400" fill="none"
                                stroke="currentColor" viewBox="0 0 24 24">
                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                                    d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z"></path>
                            </svg> --}}
                        </div>
                    </div>
                    <div class="flex gap-3">
                        <select name="role" class="form-input w-auto">
                            <option value="">Semua Role</option>
                            <option value="ketua" {{ request('role') == 'ketua' ? 'selected' : '' }}>Ketua</option>
                            <option value="gapoktan" {{ request('role') == 'gapoktan' ? 'selected' : '' }}>Gapoktan</option>
                        </select>
                        <button type="submit" class="btn btn-primary">Filter</button>
                        <a href="{{ route('admin.users.index') }}" class="btn btn-secondary">Reset</a>
                    </div>
                </form>
            </div>
        </div>

        <!-- Bulk Actions -->
        <div id="bulk-actions" class="hidden items-center gap-4 p-4 bg-teal-50 rounded-lg border border-teal-200">
            <span class="text-sm text-[#040316]"><span id="selected-count">0</span> item dipilih</span>
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
        <div class="card">
            <div class="table-container">
                <table class="w-full">
                    <thead class="bg-gray-50">
                        <tr>
                            <th class="px-4 py-3 text-left">
                                <input type="checkbox" id="select-all" class="checkbox" onchange="toggleSelectAll()">
                            </th>
                            <th class="px-4 py-3 text-left text-xs font-semibold text-gray-600 uppercase tracking-wider">
                                User</th>
                            <th class="px-4 py-3 text-left text-xs font-semibold text-gray-600 uppercase tracking-wider">
                                Email</th>
                            <th class="px-4 py-3 text-left text-xs font-semibold text-gray-600 uppercase tracking-wider">
                                Role</th>
                            <th class="px-4 py-3 text-left text-xs font-semibold text-gray-600 uppercase tracking-wider">
                                Jabatan</th>
                            <th class="px-4 py-3 text-left text-xs font-semibold text-gray-600 uppercase tracking-wider">
                                Terdaftar</th>
                            <th class="px-4 py-3 text-right text-xs font-semibold text-gray-600 uppercase tracking-wider">
                                Aksi</th>
                        </tr>
                    </thead>
                    <tbody class="divide-y divide-gray-200">
                        @forelse($users as $user)
                            <tr class="hover:bg-gray-50 transition-colors" data-id="{{ $user->id }}">
                                <td class="px-4 py-3">
                                    <input type="checkbox" class="checkbox row-checkbox" value="{{ $user->id }}"
                                        onchange="updateBulkActions()">
                                </td>
                                <td class="px-4 py-3">
                                    <div class="flex items-center gap-3">
                                        <div
                                            class="w-10 h-10 rounded-full bg-[#d1d1d1] flex items-center justify-center text-[#0b1319] font-semibold">
                                            {{ strtoupper(substr($user->nama_pengguna, 0, 2)) }}
                                        </div>
                                        <div>
                                            <p class="font-medium text-gray-900">{{ $user->nama_pengguna }}</p>
                                            <p class="text-xs text-gray-500">#{{ $user->id }}</p>
                                        </div>
                                    </div>
                                </td>
                                <td class="px-4 py-3">
                                    <span class="text-sm text-gray-600">{{ $user->email }}</span>
                                </td>
                                <td class="px-4 py-3">
                                    <span class="badge {{ $user->role == 'ketua' ? 'badge-primary' : 'badge-info' }}">
                                        {{ ucfirst($user->role ?? 'N/A') }}
                                    </span>
                                </td>
                                <td class="px-4 py-3">
                                    <span
                                        class="text-sm text-gray-600">{{ $user->profil?->jabatan?->jabatan ?? '-' }}</span>
                                </td>
                                <td class="px-4 py-3">
                                    <span class="text-sm text-gray-600">{{ $user->created_at->format('d M Y') }}</span>
                                </td>
                                <td class="px-4 py-3">
                                    <div class="flex items-center justify-end gap-2">
                                        <button onclick="showUser({{ $user->id }})"
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
                                        <button onclick="showEditModal({{ $user->id }})"
                                            class="btn-icon text-gray-400 hover:text-teal-600 hover:bg-teal-50"
                                            title="Edit">
                                            <svg class="w-4 h-4" fill="none" stroke="currentColor"
                                                viewBox="0 0 24 24">
                                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                                                    d="M11 5H6a2 2 0 00-2 2v11a2 2 0 002 2h11a2 2 0 002-2v-5m-1.414-9.414a2 2 0 112.828 2.828L11.828 15H9v-2.828l8.586-8.586z">
                                                </path>
                                            </svg>
                                        </button>
                                        <button onclick="deleteUser({{ $user->id }})"
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
                                            d="M12 4.354a4 4 0 110 5.292M15 21H3v-1a6 6 0 0112 0v1zm0 0h6v-1a6 6 0 00-9-5.197M13 7a4 4 0 11-8 0 4 4 0 018 0z">
                                        </path>
                                    </svg>
                                    Tidak ada data user
                                </td>
                            </tr>
                        @endforelse
                    </tbody>
                </table>
            </div>

            <!-- Pagination -->
            @if ($users->hasPages())
                <div class="px-4 py-3 border-t border-gray-200">
                    {{ $users->links() }}
                </div>
            @endif
        </div>
    </div>

    <!-- Jabatan Options for JS -->
    <script>
        const jabatanOptions = @json($jabatans);
    </script>
@endsection

@push('scripts')
    <script>
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

            if (checked.length > 0) {
                bulkActions.classList.remove('hidden');
                bulkActions.classList.add('flex');
                selectedCount.textContent = checked.length;
            } else {
                bulkActions.classList.add('hidden');
                bulkActions.classList.remove('flex');
            }
        }

        // Get selected IDs
        function getSelectedIds() {
            return Array.from(document.querySelectorAll('.row-checkbox:checked')).map(cb => cb.value);
        }

        // Show create modal
        function showCreateModal() {
            showModal({
                title: 'Tambah User Baru',
                size: 'md',
                content: `
                <form id="create-user-form" class="space-y-4">
                    <div>
                        <label class="form-label">Nama Pengguna <span class="text-red-500">*</span></label>
                        <input type="text" name="nama_pengguna" class="form-input" required>
                    </div>
                    <div>
                        <label class="form-label">Email <span class="text-red-500">*</span></label>
                        <input type="email" name="email" class="form-input" required>
                    </div>
                    <div>
                        <label class="form-label">Password <span class="text-red-500">*</span></label>
                        <input type="password" name="password" class="form-input" required minlength="8">
                    </div>
                    <div>
                        <label class="form-label">Konfirmasi Password <span class="text-red-500">*</span></label>
                        <input type="password" name="password_confirmation" class="form-input" required>
                    </div>
                    <div>
                        <label class="form-label">Role <span class="text-red-500">*</span></label>
                        <select name="role" class="form-input" required>
                            <option value="">Pilih Role</option>
                            <option value="ketua">Ketua</option>
                            <option value="gapoktan">Gapoktan</option>
                        </select>
                    </div>
                    <div>
                        <label class="form-label">Jabatan</label>
                        <select name="id_jabatan" class="form-input">
                            <option value="">Pilih Jabatan (Opsional)</option>
                            ${jabatanOptions.map(j => `<option value="${j.id}">${j.jabatan}</option>`).join('')}
                        </select>
                    </div>
                </form>
            `,
                confirmText: 'Simpan',
                onConfirm: createUser
            });
        }

        // Create user
        async function createUser() {
            const form = document.getElementById('create-user-form');
            const formData = new FormData(form);
            const data = Object.fromEntries(formData);

            try {
                const response = await fetchApi('{{ route('admin.users.store') }}', {
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

        // Show user detail
        async function showUser(id) {
            try {
                const response = await fetchApi(`/admin/users/${id}`);
                const user = response.data;

                showModal({
                    title: 'Detail User',
                    size: 'md',
                    content: `
                    <div class="space-y-4">
                        <div class="flex items-center gap-4">
                            <div class="w-16 h-16 rounded-full bg-teal-100 flex items-center justify-center text-teal-600 text-xl font-bold">
                                ${user.nama_pengguna.substring(0, 2).toUpperCase()}
                            </div>
                            <div>
                                <h3 class="text-lg font-semibold text-gray-900">${user.nama_pengguna}</h3>
                                <p class="text-gray-500">${user.email}</p>
                            </div>
                        </div>
                        <div class="grid grid-cols-2 gap-4 pt-4 border-t">
                            <div>
                                <p class="text-sm text-gray-500">ID</p>
                                <p class="font-medium">#${user.id}</p>
                            </div>
                            <div>
                                <p class="text-sm text-gray-500">Role</p>
                                <p class="font-medium capitalize">${user.role || 'N/A'}</p>
                            </div>
                            <div>
                                <p class="text-sm text-gray-500">Jabatan</p>
                                <p class="font-medium">${user.profil?.jabatan?.jabatan || '-'}</p>
                            </div>
                            <div>
                                <p class="text-sm text-gray-500">Terdaftar</p>
                                <p class="font-medium">${new Date(user.created_at).toLocaleDateString('id-ID')}</p>
                            </div>
                        </div>
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
                const response = await fetchApi(`/admin/users/${id}/edit`);
                const user = response.data;

                showModal({
                    title: 'Edit User',
                    size: 'md',
                    content: `
                    <form id="edit-user-form" class="space-y-4">
                        <div>
                            <label class="form-label">Nama Pengguna <span class="text-red-500">*</span></label>
                            <input type="text" name="nama_pengguna" value="${user.nama_pengguna}" class="form-input" required>
                        </div>
                        <div>
                            <label class="form-label">Email <span class="text-red-500">*</span></label>
                            <input type="email" name="email" value="${user.email}" class="form-input" required>
                        </div>
                        <div>
                            <label class="form-label">Password Baru</label>
                            <input type="password" name="password" class="form-input" placeholder="Kosongkan jika tidak ingin mengubah">
                        </div>
                        <div>
                            <label class="form-label">Konfirmasi Password</label>
                            <input type="password" name="password_confirmation" class="form-input">
                        </div>
                        <div>
                            <label class="form-label">Role <span class="text-red-500">*</span></label>
                            <select name="role" class="form-input" required>
                                <option value="ketua" ${user.role === 'ketua' ? 'selected' : ''}>Ketua</option>
                                <option value="gapoktan" ${user.role === 'gapoktan' ? 'selected' : ''}>Gapoktan</option>
                            </select>
                        </div>
                        <div>
                            <label class="form-label">Jabatan</label>
                            <select name="id_jabatan" class="form-input">
                                <option value="">Pilih Jabatan (Opsional)</option>
                                ${jabatanOptions.map(j => `<option value="${j.id}" ${user.profil?.id_jabatan == j.id ? 'selected' : ''}>${j.jabatan}</option>`).join('')}
                            </select>
                        </div>
                    </form>
                `,
                    confirmText: 'Update',
                    onConfirm: () => updateUser(id)
                });
            } catch (error) {
                showToast(error.message, 'error');
            }
        }

        // Update user
        async function updateUser(id) {
            const form = document.getElementById('edit-user-form');
            const formData = new FormData(form);
            const data = Object.fromEntries(formData);

            try {
                const response = await fetchApi(`/admin/users/${id}`, {
                    method: 'PUT',
                    body: JSON.stringify(data)
                });

                showToast(response.message, 'success');
                closeModal();
                setTimeout(() => location.reload(), 500);
            } catch (error) {
                showToast(error.message, 'error');
            }
        }

        // Delete user
        function deleteUser(id) {
            confirmDialog('Apakah Anda yakin ingin menghapus user ini?', async () => {
                try {
                    const response = await fetchApi(`/admin/users/${id}`, {
                        method: 'DELETE'
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
            confirmDialog(`Apakah Anda yakin ingin menghapus ${ids.length} user?`, async () => {
                try {
                    const response = await fetchApi('{{ route('admin.users.bulk-destroy') }}', {
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
    </script>
@endpush
