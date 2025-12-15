<!-- Header -->
<header class="h-16 bg-white border-b border-gray-200 flex items-center justify-between px-6 sticky top-0 z-10">
    <!-- Left Side -->
    <div class="flex items-center gap-4">
        <!-- Mobile Menu Button -->
        <button
            class="sidebar-hamburger lg:hidden flex items-center justify-center w-10 h-10 rounded-md text-gray-700 hover:bg-gray-100 focus:outline-none focus:ring-2 focus:ring-[#0b1319]/30 mr-2"
            type="button" aria-label="Open sidebar" onclick="openSidebar()">
            <i class="fa-solid fa-bars fa-lg"></i>
        </button>

        <!-- Breadcrumb -->
        <nav class="hidden sm:flex items-center gap-2 text-sm">
            <a href="{{ route('admin.dashboard') }}" class="text-gray-500 hover:text-gray-700">Home</a>
            @hasSection('breadcrumb')
                <svg class="w-4 h-4 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 5l7 7-7 7"></path>
                </svg>
                @yield('breadcrumb')
            @endif
        </nav>
    </div>

    <!-- Right Side -->
    <div class="flex items-center gap-3">
        <!-- Search (Desktop) -->
        <div class="hidden md:block relative">
            <input type="text" placeholder="Search..."
                class="w-64 bg-gray-50 border border-gray-200 rounded-lg pl-10 pr-4 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-teal-500/50 focus:border-teal-500">
            <svg class="w-4 h-4 absolute left-3 top-1/2 -translate-y-1/2 text-gray-400" fill="none"
                stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                    d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z"></path>
            </svg>
        </div>

        <!-- Notifications -->
        <div class="relative">
            <button id="notification-btn"
                class="relative p-2 text-gray-500 hover:text-gray-700 hover:bg-gray-100 rounded-lg">
                <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                        d="M15 17h5l-1.405-1.405A2.032 2.032 0 0118 14.158V11a6.002 6.002 0 00-4-5.659V5a2 2 0 10-4 0v.341C7.67 6.165 6 8.388 6 11v3.159c0 .538-.214 1.055-.595 1.436L4 17h5m6 0v1a3 3 0 11-6 0v-1m6 0H9">
                    </path>
                </svg>
                <span class="absolute top-1 right-1 w-2 h-2 bg-red-500 rounded-full"></span>
            </button>

            <!-- Notification Dropdown -->
            <div id="notification-dropdown" class="dropdown-menu hidden w-80">
                <div class="p-4 border-b border-gray-100">
                    <div class="flex items-center justify-between">
                        <h3 class="font-semibold text-gray-900">Notifications</h3>
                        <span class="text-xs text-teal-600 bg-teal-50 px-2 py-1 rounded-full">3 new</span>
                    </div>
                </div>
                <div class="max-h-64 overflow-y-auto">
                    <a href="#" class="block px-4 py-3 hover:bg-gray-50 border-b border-gray-100">
                        <div class="flex gap-3">
                            <div
                                class="w-8 h-8 bg-teal-100 rounded-full flex items-center justify-center flex-shrink-0">
                                <svg class="w-4 h-4 text-teal-600" fill="none" stroke="currentColor"
                                    viewBox="0 0 24 24">
                                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                                        d="M16 7a4 4 0 11-8 0 4 4 0 018 0zM12 14a7 7 0 00-7 7h14a7 7 0 00-7-7z"></path>
                                </svg>
                            </div>
                            <div class="flex-1 min-w-0">
                                <p class="text-sm font-medium text-gray-900">User baru terdaftar</p>
                                <p class="text-xs text-gray-500 truncate">John Doe mendaftar sebagai ketua</p>
                                <p class="text-xs text-gray-400 mt-1">5 menit yang lalu</p>
                            </div>
                        </div>
                    </a>
                    <a href="#" class="block px-4 py-3 hover:bg-gray-50 border-b border-gray-100">
                        <div class="flex gap-3">
                            <div
                                class="w-8 h-8 bg-blue-100 rounded-full flex items-center justify-center flex-shrink-0">
                                <svg class="w-4 h-4 text-blue-600" fill="none" stroke="currentColor"
                                    viewBox="0 0 24 24">
                                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                                        d="M8 7V3m8 4V3m-9 8h10M5 21h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v12a2 2 0 002 2z">
                                    </path>
                                </svg>
                            </div>
                            <div class="flex-1 min-w-0">
                                <p class="text-sm font-medium text-gray-900">Kegiatan baru ditambahkan</p>
                                <p class="text-xs text-gray-500 truncate">Penanaman padi dimulai besok</p>
                                <p class="text-xs text-gray-400 mt-1">1 jam yang lalu</p>
                            </div>
                        </div>
                    </a>
                </div>
                <div class="p-3 border-t border-gray-100">
                    <a href="#"
                        class="block text-center text-sm text-teal-600 hover:text-teal-700 font-medium">Lihat semua
                        notifikasi</a>
                </div>
            </div>
        </div>

        <!-- Profile Dropdown -->
        <div class="relative">
            <button id="profile-btn" class="flex items-center gap-3 p-1.5 hover:bg-gray-100 rounded-lg">
                <div
                    class="w-8 h-8 rounded-full bg-teal-500 flex items-center justify-center text-white text-sm font-semibold">
                    {{ Auth::guard('admin')->user()->initials }}
                </div>
                <div class="hidden sm:block text-left">
                    <p class="text-sm font-medium text-gray-700">{{ Auth::guard('admin')->user()->name }}</p>
                    <p class="text-xs text-gray-500">{{ ucfirst(Auth::guard('admin')->user()->role) }}</p>
                </div>
                <svg class="w-4 h-4 text-gray-400 hidden sm:block" fill="none" stroke="currentColor"
                    viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 9l-7 7-7-7"></path>
                </svg>
            </button>

            <!-- Profile Dropdown Menu -->
            <div id="profile-dropdown" class="dropdown-menu hidden">
                <div class="p-4 border-b border-gray-100">
                    <p class="font-medium text-gray-900">{{ Auth::guard('admin')->user()->name }}</p>
                    <p class="text-sm text-gray-500">{{ Auth::guard('admin')->user()->email }}</p>
                </div>
                <div class="py-2">
                    <a href="#" onclick="showProfileModal()"
                        class="flex items-center gap-3 px-4 py-2 text-sm text-gray-700 hover:bg-gray-50">
                        <svg class="w-4 h-4 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                                d="M16 7a4 4 0 11-8 0 4 4 0 018 0zM12 14a7 7 0 00-7 7h14a7 7 0 00-7-7z"></path>
                        </svg>
                        Edit Profile
                    </a>
                    <a href="#"
                        class="flex items-center gap-3 px-4 py-2 text-sm text-gray-700 hover:bg-gray-50">
                        <svg class="w-4 h-4 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                                d="M10.325 4.317c.426-1.756 2.924-1.756 3.35 0a1.724 1.724 0 002.573 1.066c1.543-.94 3.31.826 2.37 2.37a1.724 1.724 0 001.065 2.572c1.756.426 1.756 2.924 0 3.35a1.724 1.724 0 00-1.066 2.573c.94 1.543-.826 3.31-2.37 2.37a1.724 1.724 0 00-2.572 1.065c-.426 1.756-2.924 1.756-3.35 0a1.724 1.724 0 00-2.573-1.066c-1.543.94-3.31-.826-2.37-2.37a1.724 1.724 0 00-1.065-2.572c-1.756-.426-1.756-2.924 0-3.35a1.724 1.724 0 001.066-2.573c-.94-1.543.826-3.31 2.37-2.37.996.608 2.296.07 2.572-1.065z">
                            </path>
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                                d="M15 12a3 3 0 11-6 0 3 3 0 016 0z"></path>
                        </svg>
                        Settings
                    </a>
                </div>
                <div class="py-2 border-t border-gray-100">
                    <form action="{{ route('admin.logout') }}" method="POST">
                        @csrf
                        <button type="submit"
                            class="flex items-center gap-3 px-4 py-2 text-sm text-red-600 hover:bg-red-50 w-full">
                            <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                                    d="M17 16l4-4m0 0l-4-4m4 4H7m6 4v1a3 3 0 01-3 3H6a3 3 0 01-3-3V7a3 3 0 013-3h4a3 3 0 013 3v1">
                                </path>
                            </svg>
                            Logout
                        </button>
                    </form>
                </div>
            </div>
        </div>
    </div>
</header>

<script>
    // Dropdown toggle
    document.getElementById('notification-btn')?.addEventListener('click', function(e) {
        e.stopPropagation();
        document.getElementById('notification-dropdown').classList.toggle('hidden');
        document.getElementById('profile-dropdown').classList.add('hidden');
    });

    document.getElementById('profile-btn')?.addEventListener('click', function(e) {
        e.stopPropagation();
        document.getElementById('profile-dropdown').classList.toggle('hidden');
        document.getElementById('notification-dropdown').classList.add('hidden');
    });

    // Close dropdowns when clicking outside
    document.addEventListener('click', function() {
        document.getElementById('notification-dropdown')?.classList.add('hidden');
        document.getElementById('profile-dropdown')?.classList.add('hidden');
    });

    // Profile Modal
    function showProfileModal() {
        showModal({
            title: 'Edit Profile',
            content: `
                <form id="profile-form" class="space-y-4">
                    <div>
                        <label class="form-label">Nama</label>
                        <input type="text" name="name" value="{{ Auth::guard('admin')->user()->name }}" class="form-input" required>
                    </div>
                    <div>
                        <label class="form-label">Email</label>
                        <input type="email" name="email" value="{{ Auth::guard('admin')->user()->email }}" class="form-input" required>
                    </div>
                    <div>
                        <label class="form-label">Password Saat Ini</label>
                        <input type="password" name="current_password" class="form-input" placeholder="Kosongkan jika tidak ingin mengubah password">
                    </div>
                    <div>
                        <label class="form-label">Password Baru</label>
                        <input type="password" name="new_password" class="form-input" placeholder="Minimal 8 karakter">
                    </div>
                    <div>
                        <label class="form-label">Konfirmasi Password Baru</label>
                        <input type="password" name="new_password_confirmation" class="form-input">
                    </div>
                </form>
            `,
            confirmText: 'Simpan',
            onConfirm: async () => {
                const form = document.getElementById('profile-form');
                const formData = new FormData(form);
                const data = Object.fromEntries(formData);

                try {
                    const response = await fetchApi('{{ route('admin.profile.update') }}', {
                        method: 'PUT',
                        body: JSON.stringify(data)
                    });

                    showToast(response.message, 'success');
                    closeModal();
                    setTimeout(() => location.reload(), 1000);
                } catch (error) {
                    showToast(error.message, 'error');
                }
            }
        });
    }
</script>
