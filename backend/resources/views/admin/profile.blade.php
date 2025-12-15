@extends('admin.layouts.app')

@section('title', 'Profil Saya')

@section('breadcrumb')
    <span class="text-gray-700 font-medium">Profil</span>
@endsection

@section('content')
    <div class="max-w-3xl mx-auto space-y-6">
        <!-- Profile Header -->
        <div class="card">
            <div class="card-body">
                <div class="flex flex-col sm:flex-row items-center gap-6">
                    <div class="relative">
                        <div
                            class="w-24 h-24 rounded-full {{ Auth::guard('admin')->user()->role == 'superadmin' ? 'bg-purple-100' : 'bg-[#d1d1d1]' }} flex items-center justify-center text-3xl font-bold {{ Auth::guard('admin')->user()->role == 'superadmin' ? 'text-purple-600' : 'text-[#0b1319]' }}">
                            {{ Auth::guard('admin')->user()->initials }}
                        </div>
                        <button
                            class="absolute bottom-0 right-0 w-8 h-8 rounded-full bg-[#0b1319] text-white flex items-center justify-center shadow-lg hover:bg-[#8b8e92] transition-colors">
                            <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                                    d="M3 9a2 2 0 012-2h.93a2 2 0 001.664-.89l.812-1.22A2 2 0 0110.07 4h3.86a2 2 0 011.664.89l.812 1.22A2 2 0 0018.07 7H19a2 2 0 012 2v9a2 2 0 01-2 2H5a2 2 0 01-2-2V9z">
                                </path>
                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                                    d="M15 13a3 3 0 11-6 0 3 3 0 016 0z"></path>
                            </svg>
                        </button>
                    </div>
                    <div class="text-center sm:text-left">
                        <h2 class="text-2xl font-bold text-gray-900">{{ Auth::guard('admin')->user()->name }}</h2>
                        <p class="text-gray-500">{{ Auth::guard('admin')->user()->email }}</p>
                        <span
                            class="inline-block mt-2 badge {{ Auth::guard('admin')->user()->role == 'superadmin' ? 'bg-purple-100 text-purple-700' : 'badge-primary' }}">
                            {{ ucfirst(Auth::guard('admin')->user()->role) }}
                        </span>
                    </div>
                </div>
            </div>
        </div>

        <!-- Profile Info Card -->
        <div class="card">
            <div class="card-header">
                <h3 class="card-title">Informasi Akun</h3>
            </div>
            <div class="card-body">
                <form id="profile-form" class="space-y-6">
                    <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
                        <div>
                            <label class="form-label">Nama Lengkap <span class="text-red-500">*</span></label>
                            <input type="text" name="name" value="{{ Auth::guard('admin')->user()->name }}"
                                class="form-input" required>
                        </div>
                        <div>
                            <label class="form-label">Email <span class="text-red-500">*</span></label>
                            <input type="email" name="email" value="{{ Auth::guard('admin')->user()->email }}"
                                class="form-input" required>
                        </div>
                    </div>
                    <div class="flex justify-end">
                        <button type="button" onclick="updateProfile()" class="btn btn-primary">
                            <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7">
                                </path>
                            </svg>
                            Simpan Perubahan
                        </button>
                    </div>
                </form>
            </div>
        </div>

        <!-- Password Card -->
        <div class="card">
            <div class="card-header">
                <h3 class="card-title">Ubah Password</h3>
            </div>
            <div class="card-body">
                <form id="password-form" class="space-y-6">
                    <div>
                        <label class="form-label">Password Saat Ini <span class="text-red-500">*</span></label>
                        <div class="relative">
                            <input type="password" name="current_password" id="current_password" class="form-input pr-10"
                                required>
                            <button type="button" onclick="togglePassword('current_password')"
                                class="absolute right-3 top-1/2 -translate-y-1/2 text-gray-400 hover:text-gray-600">
                                <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                                        d="M15 12a3 3 0 11-6 0 3 3 0 016 0z"></path>
                                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                                        d="M2.458 12C3.732 7.943 7.523 5 12 5c4.478 0 8.268 2.943 9.542 7-1.274 4.057-5.064 7-9.542 7-4.477 0-8.268-2.943-9.542-7z">
                                    </path>
                                </svg>
                            </button>
                        </div>
                    </div>
                    <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
                        <div>
                            <label class="form-label">Password Baru <span class="text-red-500">*</span></label>
                            <div class="relative">
                                <input type="password" name="new_password" id="new_password" class="form-input pr-10"
                                    required minlength="8">
                                <button type="button" onclick="togglePassword('new_password')"
                                    class="absolute right-3 top-1/2 -translate-y-1/2 text-gray-400 hover:text-gray-600">
                                    <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                                            d="M15 12a3 3 0 11-6 0 3 3 0 016 0z"></path>
                                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                                            d="M2.458 12C3.732 7.943 7.523 5 12 5c4.478 0 8.268 2.943 9.542 7-1.274 4.057-5.064 7-9.542 7-4.477 0-8.268-2.943-9.542-7z">
                                        </path>
                                    </svg>
                                </button>
                            </div>
                        </div>
                        <div>
                            <label class="form-label">Konfirmasi Password <span class="text-red-500">*</span></label>
                            <div class="relative">
                                <input type="password" name="new_password_confirmation" id="new_password_confirmation"
                                    class="form-input pr-10" required>
                                <button type="button" onclick="togglePassword('new_password_confirmation')"
                                    class="absolute right-3 top-1/2 -translate-y-1/2 text-gray-400 hover:text-gray-600">
                                    <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                                            d="M15 12a3 3 0 11-6 0 3 3 0 016 0z"></path>
                                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                                            d="M2.458 12C3.732 7.943 7.523 5 12 5c4.478 0 8.268 2.943 9.542 7-1.274 4.057-5.064 7-9.542 7-4.477 0-8.268-2.943-9.542-7z">
                                        </path>
                                    </svg>
                                </button>
                            </div>
                        </div>
                    </div>
                    <div class="flex justify-end">
                        <button type="button" onclick="updatePassword()" class="btn btn-primary">
                            <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                                    d="M12 15v2m-6 4h12a2 2 0 002-2v-6a2 2 0 00-2-2H6a2 2 0 00-2 2v6a2 2 0 002 2zm10-10V7a4 4 0 00-8 0v4h8z">
                                </path>
                            </svg>
                            Ubah Password
                        </button>
                    </div>
                </form>
            </div>
        </div>

        <!-- Account Info -->
        <div class="card">
            <div class="card-header">
                <h3 class="card-title">Informasi Tambahan</h3>
            </div>
            <div class="card-body">
                <dl class="grid grid-cols-1 md:grid-cols-2 gap-6">
                    <div>
                        <dt class="text-sm font-medium text-gray-500">ID Akun</dt>
                        <dd class="mt-1 text-sm text-gray-900">{{ Auth::guard('admin')->user()->id }}</dd>
                    </div>
                    <div>
                        <dt class="text-sm font-medium text-gray-500">Role</dt>
                        <dd class="mt-1 text-sm text-gray-900">{{ ucfirst(Auth::guard('admin')->user()->role) }}</dd>
                    </div>
                    <div>
                        <dt class="text-sm font-medium text-gray-500">Akun Dibuat</dt>
                        <dd class="mt-1 text-sm text-gray-900">
                            {{ Auth::guard('admin')->user()->created_at->format('d M Y, H:i') }}</dd>
                    </div>
                    <div>
                        <dt class="text-sm font-medium text-gray-500">Login Terakhir</dt>
                        <dd class="mt-1 text-sm text-gray-900">
                            {{ Auth::guard('admin')->user()->last_login_at ? Auth::guard('admin')->user()->last_login_at->format('d M Y, H:i') : 'Belum pernah login' }}
                        </dd>
                    </div>
                </dl>
            </div>
        </div>
    </div>
@endsection

@push('scripts')
    <script>
        // Toggle password visibility
        function togglePassword(inputId) {
            const input = document.getElementById(inputId);
            input.type = input.type === 'password' ? 'text' : 'password';
        }

        // Update profile
        async function updateProfile() {
            const form = document.getElementById('profile-form');
            const formData = new FormData(form);
            const data = Object.fromEntries(formData);

            try {
                const response = await fetchApi('{{ route('admin.profile.update') }}', {
                    method: 'PUT',
                    body: JSON.stringify(data)
                });

                showToast(response.message, 'success');
                setTimeout(() => location.reload(), 500);
            } catch (error) {
                showToast(error.message, 'error');
            }
        }

        // Update password
        async function updatePassword() {
            const form = document.getElementById('password-form');
            const formData = new FormData(form);
            const data = Object.fromEntries(formData);

            if (data.new_password !== data.new_password_confirmation) {
                showToast('Password baru tidak cocok', 'error');
                return;
            }

            try {
                const response = await fetchApi('{{ route('admin.profile.update') }}', {
                    method: 'PUT',
                    body: JSON.stringify(data)
                });

                showToast(response.message, 'success');
                form.reset();
            } catch (error) {
                showToast(error.message, 'error');
            }
        }
    </script>
@endpush
