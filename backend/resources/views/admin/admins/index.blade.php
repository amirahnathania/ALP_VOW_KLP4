@extends('admin.layouts.app')

@section('title', 'Admin Management')

@section('breadcrumb')
    <span class="text-gray-700 font-medium">Admin Management</span>
@endsection

@section('content')
    <div class="space-y-6">
        <!-- Page Header -->
        <div class="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-4">
            <div>
                <h1 class="text-2xl font-bold text-gray-900">Admin Management</h1>
                <p class="text-gray-500 mt-1">Kelola akun administrator</p>
            </div>
            <button onclick="showCreateModal()" class="btn btn-primary">
                <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 6v6m0 0v6m0-6h6m-6 0H6">
                    </path>
                </svg>
                Tambah Admin
            </button>
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
                            <option value="superadmin" {{ request('role') == 'superadmin' ? 'selected' : '' }}>Super Admin
                            </option>
                            <option value="admin" {{ request('role') == 'admin' ? 'selected' : '' }}>Admin</option>
                        </select>
                        <button type="submit" class="btn btn-primary">Filter</button>
                        <a href="{{ route('admin.admins.index') }}" class="btn btn-secondary">Reset</a>
                    </div>
                </form>
            </div>
        </div>

        <!-- Table -->
        <div class="card">
            <div class="table-container">
                <table class="w-full">
                    <thead class="bg-gray-50">
                        <tr>
                            <th class="px-4 py-3 text-left text-xs font-semibold text-gray-600 uppercase tracking-wider">
                                Admin</th>
                            <th class="px-4 py-3 text-left text-xs font-semibold text-gray-600 uppercase tracking-wider">
                                Email</th>
                            <th class="px-4 py-3 text-left text-xs font-semibold text-gray-600 uppercase tracking-wider">
                                Role</th>
                            <th class="px-4 py-3 text-left text-xs font-semibold text-gray-600 uppercase tracking-wider">
                                Status</th>
                            <th class="px-4 py-3 text-left text-xs font-semibold text-gray-600 uppercase tracking-wider">
                                Last Login</th>
                            <th class="px-4 py-3 text-right text-xs font-semibold text-gray-600 uppercase tracking-wider">
                                Aksi</th>
                        </tr>
                    </thead>
                    <tbody class="divide-y divide-gray-200">
                        @forelse($admins as $admin)
                            <tr class="hover:bg-gray-50 transition-colors">
                                <td class="px-4 py-3">
                                    <div class="flex items-center gap-3">
                                        <div
                                            class="w-10 h-10 rounded-full {{ $admin->role == 'superadmin' ? 'bg-purple-100' : 'bg-[#d1d1d1]' }} flex items-center justify-center font-semibold {{ $admin->role == 'superadmin' ? 'text-purple-600' : 'text-[#0b1319]' }}">
                                            {{ $admin->initials }}
                                        </div>
                                        <div>
                                            <p class="font-medium text-gray-900">{{ $admin->name }}</p>
                                            <p class="text-xs text-gray-500">#{{ $admin->id }}</p>
                                        </div>
                                    </div>
                                </td>
                                <td class="px-4 py-3">
                                    <span class="text-sm text-gray-600">{{ $admin->email }}</span>
                                </td>
                                <td class="px-4 py-3">
                                    <span
                                        class="badge {{ $admin->role == 'superadmin' ? 'bg-purple-100 text-purple-700' : 'badge-primary' }}">
                                        {{ ucfirst($admin->role) }}
                                    </span>
                                </td>
                                <td class="px-4 py-3">
                                    <button onclick="toggleStatus({{ $admin->id }})"
                                        class="badge {{ $admin->is_active ? 'badge-success' : 'badge-danger' }} cursor-pointer hover:opacity-80"
                                        {{ $admin->id === Auth::guard('admin')->id() ? 'disabled' : '' }}>
                                        {{ $admin->is_active ? 'Active' : 'Inactive' }}
                                    </button>
                                </td>
                                <td class="px-4 py-3">
                                    <span class="text-sm text-gray-600">
                                        {{ $admin->last_login_at ? $admin->last_login_at->diffForHumans() : 'Never' }}
                                    </span>
                                </td>
                                <td class="px-4 py-3">
                                    <div class="flex items-center justify-end gap-2">
                                        <button onclick="showEditModal({{ $admin->id }})"
                                            class="btn-icon text-gray-400 hover:text-teal-600 hover:bg-teal-50"
                                            title="Edit">
                                            <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                                                    d="M11 5H6a2 2 0 00-2 2v11a2 2 0 002 2h11a2 2 0 002-2v-5m-1.414-9.414a2 2 0 112.828 2.828L11.828 15H9v-2.828l8.586-8.586z">
                                                </path>
                                            </svg>
                                        </button>
                                        @if ($admin->id !== Auth::guard('admin')->id())
                                            <button onclick="deleteAdmin({{ $admin->id }})"
                                                class="btn-icon text-gray-400 hover:text-red-600 hover:bg-red-50"
                                                title="Hapus">
                                                <svg class="w-4 h-4" fill="none" stroke="currentColor"
                                                    viewBox="0 0 24 24">
                                                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                                                        d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16">
                                                    </path>
                                                </svg>
                                            </button>
                                        @endif
                                    </div>
                                </td>
                            </tr>
                        @empty
                            <tr>
                                <td colspan="6" class="px-4 py-8 text-center text-gray-500">
                                    <svg class="w-12 h-12 mx-auto text-gray-300 mb-3" fill="none" stroke="currentColor"
                                        viewBox="0 0 24 24">
                                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                                            d="M9 12l2 2 4-4m5.618-4.016A11.955 11.955 0 0112 2.944a11.955 11.955 0 01-8.618 3.04A12.02 12.02 0 003 9c0 5.591 3.824 10.29 9 11.622 5.176-1.332 9-6.03 9-11.622 0-1.042-.133-2.052-.382-3.016z">
                                        </path>
                                    </svg>
                                    Tidak ada data admin
                                </td>
                            </tr>
                        @endforelse
                    </tbody>
                </table>
            </div>

            <!-- Pagination -->
            @if ($admins->hasPages())
                <div class="px-4 py-3 border-t border-gray-200">
                    {{ $admins->links() }}
                </div>
            @endif
        </div>
    </div>
@endsection

@push('scripts')
    <script>
        // Admin data for editing
        const adminsData = @json($admins->items());

        // Show create modal
        function showCreateModal() {
            showModal({
                title: 'Tambah Admin Baru',
                size: 'md',
                content: `
                <form id="admin-form" class="space-y-4">
                    <div>
                        <label class="form-label">Nama <span class="text-red-500">*</span></label>
                        <input type="text" name="name" class="form-input" required>
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
                            <option value="admin">Admin</option>
                            <option value="superadmin">Super Admin</option>
                        </select>
                    </div>
                </form>
            `,
                confirmText: 'Simpan',
                onConfirm: createAdmin
            });
        }

        // Create admin
        async function createAdmin() {
            const form = document.getElementById('admin-form');
            const formData = new FormData(form);
            const data = Object.fromEntries(formData);

            try {
                const response = await fetchApi('{{ route('admin.admins.store') }}', {
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

        // Show edit modal
        function showEditModal(id) {
            const admin = adminsData.find(a => a.id === id);
            if (!admin) return;

            showModal({
                title: 'Edit Admin',
                size: 'md',
                content: `
                <form id="admin-form" class="space-y-4">
                    <div>
                        <label class="form-label">Nama <span class="text-red-500">*</span></label>
                        <input type="text" name="name" value="${admin.name}" class="form-input" required>
                    </div>
                    <div>
                        <label class="form-label">Email <span class="text-red-500">*</span></label>
                        <input type="email" name="email" value="${admin.email}" class="form-input" required>
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
                            <option value="admin" ${admin.role === 'admin' ? 'selected' : ''}>Admin</option>
                            <option value="superadmin" ${admin.role === 'superadmin' ? 'selected' : ''}>Super Admin</option>
                        </select>
                    </div>
                    <div class="flex items-center gap-2">
                        <input type="checkbox" name="is_active" id="is_active" class="checkbox" ${admin.is_active ? 'checked' : ''}>
                        <label for="is_active" class="text-sm text-gray-600">Aktif</label>
                    </div>
                </form>
            `,
                confirmText: 'Update',
                onConfirm: () => updateAdmin(id)
            });
        }

        // Update admin
        async function updateAdmin(id) {
            const form = document.getElementById('admin-form');
            const formData = new FormData(form);
            const data = Object.fromEntries(formData);
            data.is_active = form.querySelector('[name="is_active"]').checked;

            try {
                const response = await fetchApi(`/admin/admins/${id}`, {
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

        // Toggle status
        async function toggleStatus(id) {
            try {
                const response = await fetchApi(`/admin/admins/${id}/toggle-status`, {
                    method: 'POST'
                });

                showToast(response.message, 'success');
                setTimeout(() => location.reload(), 500);
            } catch (error) {
                showToast(error.message, 'error');
            }
        }

        // Delete admin
        function deleteAdmin(id) {
            confirmDialog('Apakah Anda yakin ingin menghapus admin ini?', async () => {
                try {
                    const response = await fetchApi(`/admin/admins/${id}`, {
                        method: 'DELETE'
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
