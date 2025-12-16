<!-- Header -->
<header class="h-16 bg-white border-b border-gray-200 flex items-center justify-between px-4 md:px-6 sticky top-0 z-50">
    <!-- Left Side -->
    <div class="flex items-center gap-3">
        <!-- Mobile Menu Button -->
        <button id="hamburger-btn" type="button"
            class="lg:hidden flex items-center justify-center w-10 h-10 rounded-lg text-gray-700 hover:bg-gray-100 transition-colors touch-manipulation"
            aria-label="Open sidebar">
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
    <div class="flex items-center gap-2 md:gap-3">
        <!-- Search (Mobile - Expandable) -->
        <div id="mobile-search-container" class="md:hidden relative transition-all duration-300 ease-in-out h-10 flex items-center"
            style="width: 40px;">
            <button id="mobile-search-icon" type="button"
                class="absolute right-0 top-1/2 -translate-y-1/2 p-2 text-gray-500 hover:text-gray-700 hover:bg-gray-100 rounded-lg transition-colors touch-manipulation z-10">
                <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                        d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z"></path>
                </svg>
            </button>
            <input type="text" id="mobile-search-input-inline" placeholder="Search..."
                class="w-full h-full bg-gray-50 border border-gray-200 rounded-lg pl-9 pr-2 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-[#386158] focus:border-[#386158] opacity-0 pointer-events-none transition-opacity duration-200">
            <svg id="mobile-search-icon-inside" class="w-4 h-4 absolute left-3 top-1/2 -translate-y-1/2 text-gray-400 opacity-0 transition-opacity duration-200 pointer-events-none" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                    d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z"></path>
            </svg>
        </div>

        <!-- Search Bar (Desktop) -->
        <div class="hidden md:block relative">
            <input type="text" placeholder="Search..."
                class="w-64 bg-gray-50 border border-gray-200 rounded-lg pl-10 pr-4 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-[#386158] focus:border-[#386158]">
            <svg class="w-4 h-4 absolute left-3 top-1/2 -translate-y-1/2 text-gray-400" fill="none"
                stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                    d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z"></path>
            </svg>
        </div>

        <!-- Notifications -->
        <div class="relative">
            <button id="notifications-toggle" type="button"
                class="relative p-2 text-gray-500 hover:text-gray-700 hover:bg-gray-100 rounded-lg transition-colors touch-manipulation">
                <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                        d="M15 17h5l-1.405-1.405A2.032 2.032 0 0118 14.158V11a6.002 6.002 0 00-4-5.659V5a2 2 0 10-4 0v.341C7.67 6.165 6 8.388 6 11v3.159c0 .538-.214 1.055-.595 1.436L4 17h5m6 0v1a3 3 0 11-6 0v-1m6 0H9">
                    </path>
                </svg>
                <span class="absolute top-1 right-1 w-2 h-2 bg-red-500 rounded-full"></span>
            </button>

            <!-- Notification Dropdown -->
            <div id="notifications-dropdown"
                class="absolute right-0 mt-2 w-80 max-w-[calc(100vw-2rem)] bg-white rounded-lg shadow-lg border border-gray-200 opacity-0 invisible transition-all duration-200 transform translate-y-2"
                style="z-index: 1001;">
                <div class="p-4 border-b border-gray-100">
                    <div class="flex items-center justify-between">
                        <h3 class="font-semibold text-gray-900">Notifications</h3>
                        <span class="text-xs text-[#386158] bg-[#386158]/10 px-2 py-1 rounded-full">3 new</span>
                    </div>
                </div>
                <div class="max-h-64 overflow-y-auto">
                    <a href="#" class="block px-4 py-3 hover:bg-gray-50 border-b border-gray-100 transition-colors">
                        <div class="flex gap-3">
                            <div class="w-8 h-8 bg-[#386158]/10 rounded-full flex items-center justify-center flex-shrink-0">
                                <svg class="w-4 h-4 text-[#386158]" fill="none" stroke="currentColor" viewBox="0 0 24 24">
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
                    <a href="#" class="block px-4 py-3 hover:bg-gray-50 border-b border-gray-100 transition-colors">
                        <div class="flex gap-3">
                            <div class="w-8 h-8 bg-blue-100 rounded-full flex items-center justify-center flex-shrink-0">
                                <svg class="w-4 h-4 text-blue-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                                        d="M8 7V3m8 4V3m-9 8h10M5 21h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v12a2 2 0 002 2z"></path>
                                </svg>
                            </div>
                            <div class="flex-1 min-w-0">
                                <p class="text-sm font-medium text-gray-900">Kegiatan baru ditambahkan</p>
                                <p class="text-xs text-gray-500 truncate">Penanaman padi dimulai besok</p>
                                <p class="text-xs text-gray-400 mt-1">1 jam yang lalu</p>
                            </div>
                        </div>
                    </a>
                    <a href="#" class="block px-4 py-3 hover:bg-gray-50 transition-colors">
                        <div class="flex gap-3">
                            <div class="w-8 h-8 bg-yellow-100 rounded-full flex items-center justify-center flex-shrink-0">
                                <svg class="w-4 h-4 text-yellow-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                                        d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-3L13.732 4c-.77-1.333-2.694-1.333-3.464 0L3.34 16c-.77 1.333.192 3 1.732 3z"></path>
                                </svg>
                            </div>
                            <div class="flex-1 min-w-0">
                                <p class="text-sm font-medium text-gray-900">Perubahan jadwal</p>
                                <p class="text-xs text-gray-500 truncate">Kegiatan panen diundur 1 hari</p>
                                <p class="text-xs text-gray-400 mt-1">3 jam yang lalu</p>
                            </div>
                        </div>
                    </a>
                </div>
                <div class="p-3 border-t border-gray-100">
                    <a href="#" class="block text-center text-sm text-[#386158] hover:text-[#2d4a43] font-medium transition-colors">
                        Lihat semua notifikasi
                    </a>
                </div>
            </div>
        </div>

        <!-- Profile -->
        <div class="relative">
            <button id="profile-toggle" type="button"
                class="flex items-center gap-2 p-1.5 hover:bg-gray-100 rounded-lg transition-colors touch-manipulation">
                <div class="w-8 h-8 rounded-full bg-[#386158] flex items-center justify-center text-white text-sm font-semibold">
                    {{ strtoupper(substr(Auth::guard('admin')->user()->name, 0, 2)) }}
                </div>
                <div class="hidden sm:block text-left">
                    <p class="text-sm font-medium text-gray-700">{{ Auth::guard('admin')->user()->name }}</p>
                    <p class="text-xs text-gray-500">{{ ucfirst(Auth::guard('admin')->user()->role) }}</p>
                </div>
                {{-- <svg class="hidden sm:block w-4 h-4 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 9l-7 7-7-7"></path>
                </svg> --}}
            </button>

            <!-- Profile Dropdown -->
            <div id="profile-dropdown"
                class="absolute right-0 mt-2 w-72 bg-white rounded-lg shadow-lg border border-gray-200 opacity-0 invisible transition-all duration-200 transform translate-y-2"
                style="z-index: 1001;">
                <div class="p-4 border-b border-gray-100">
                    <p class="font-medium text-gray-900 truncate">{{ Auth::guard('admin')->user()->name }}</p>
                    <p class="text-sm text-gray-500 truncate">{{ Auth::guard('admin')->user()->email }}</p>
                </div>
                <div class="py-2">
                    <a href="#" onclick="event.preventDefault(); showProfileModal();"
                        class="flex items-center gap-3 px-4 py-2 text-sm text-gray-700 hover:bg-gray-50 transition-colors">
                        <svg class="w-4 h-4 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                                d="M16 7a4 4 0 11-8 0 4 4 0 018 0zM12 14a7 7 0 00-7 7h14a7 7 0 00-7-7z"></path>
                        </svg>
                        <span>Edit Profile</span>
                    </a>
                    <a href="#" onclick="event.preventDefault(); showSettings();"
                        class="flex items-center gap-3 px-4 py-2 text-sm text-gray-700 hover:bg-gray-50 transition-colors">
                        <svg class="w-4 h-4 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                                d="M10.325 4.317c.426-1.756 2.924-1.756 3.35 0a1.724 1.724 0 002.573 1.066c1.543-.94 3.31.826 2.37 2.37a1.724 1.724 0 001.065 2.572c1.756.426 1.756 2.924 0 3.35a1.724 1.724 0 00-1.066 2.573c.94 1.543-.826 3.31-2.37 2.37a1.724 1.724 0 00-2.572 1.065c-.426 1.756-2.924 1.756-3.35 0a1.724 1.724 0 00-2.573-1.066c-1.543.94-3.31-.826-2.37-2.37a1.724 1.724 0 00-1.065-2.572c-1.756-.426-1.756-2.924 0-3.35a1.724 1.724 0 001.066-2.573c-.94-1.543.826-3.31 2.37-2.37.996.608 2.296.07 2.572-1.065z"></path>
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                                d="M15 12a3 3 0 11-6 0 3 3 0 016 0z"></path>
                        </svg>
                        <span>Settings</span>
                    </a>
                </div>
                <div class="border-t border-gray-100">
                    <form action="{{ route('admin.logout') }}" method="POST" class="p-2">
                        @csrf
                        <button type="submit"
                            class="flex items-center gap-3 w-full px-4 py-2 text-sm text-red-600 hover:bg-red-50 rounded-lg transition-colors">
                            <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                                    d="M17 16l4-4m0 0l-4-4m4 4H7m6 4v1a3 3 0 01-3 3H6a3 3 0 01-3-3V7a3 3 0 013-3h4a3 3 0 013 3v1"></path>
                            </svg>
                            <span>Logout</span>
                        </button>
                    </form>
                </div>
            </div>
        </div>
    </div>
</header>

<script>
(function() {
    'use strict';

    // Wait for DOM to be ready
    document.addEventListener('DOMContentLoaded', function() {
        // Get all elements
        const hamburgerBtn = document.getElementById('hamburger-btn');
        const mobileSearchContainer = document.getElementById('mobile-search-container');
        const mobileSearchIcon = document.getElementById('mobile-search-icon');
        const mobileSearchInputInline = document.getElementById('mobile-search-input-inline');
        const notificationsToggle = document.getElementById('notifications-toggle');
        const notificationsDropdown = document.getElementById('notifications-dropdown');
        const profileToggle = document.getElementById('profile-toggle');
        const profileDropdown = document.getElementById('profile-dropdown');

        let isSearchExpanded = false;

        // Hamburger menu - call global function
        if (hamburgerBtn) {
            hamburgerBtn.addEventListener('click', function(e) {
                e.preventDefault();
                e.stopPropagation();
                console.log('Hamburger clicked');

                // Close search and notifications when opening sidebar
                collapseSearch();
                if (notificationsDropdown) {
                    notificationsDropdown.classList.add('invisible', 'opacity-0', 'translate-y-2');
                }
                if (profileDropdown) {
                    profileDropdown.classList.add('invisible', 'opacity-0', 'translate-y-2');
                }

                if (typeof openSidebar === 'function') {
                    openSidebar();
                } else {
                    console.error('openSidebar function not found');
                }
            });
        }

        // Mobile search expand/collapse
        const mobileSearchIconInside = document.getElementById('mobile-search-icon-inside');

        function expandSearch() {
            if (!isSearchExpanded && mobileSearchContainer && mobileSearchInputInline) {
                isSearchExpanded = true;
                mobileSearchContainer.style.width = '180px';
                mobileSearchInputInline.classList.remove('opacity-0', 'pointer-events-none');
                mobileSearchInputInline.classList.add('opacity-100');
                if (mobileSearchIcon) {
                    mobileSearchIcon.classList.add('opacity-0', 'pointer-events-none');
                }
                if (mobileSearchIconInside) {
                    mobileSearchIconInside.classList.remove('opacity-0');
                    mobileSearchIconInside.classList.add('opacity-100');
                }
                setTimeout(() => {
                    mobileSearchInputInline.focus();
                }, 300);
            }
        }

        function collapseSearch() {
            if (isSearchExpanded && mobileSearchContainer && mobileSearchInputInline) {
                isSearchExpanded = false;
                mobileSearchContainer.style.width = '40px';
                mobileSearchInputInline.classList.add('opacity-0', 'pointer-events-none');
                mobileSearchInputInline.classList.remove('opacity-100');
                if (mobileSearchIcon) {
                    mobileSearchIcon.classList.remove('opacity-0', 'pointer-events-none');
                }
                if (mobileSearchIconInside) {
                    mobileSearchIconInside.classList.add('opacity-0');
                    mobileSearchIconInside.classList.remove('opacity-100');
                }
                mobileSearchInputInline.value = '';
            }
        }

        if (mobileSearchIcon) {
            mobileSearchIcon.addEventListener('click', function(e) {
                e.preventDefault();
                e.stopPropagation();
                console.log('Mobile search icon clicked');
                if (!isSearchExpanded) {
                    // Close sidebar and notifications when opening search
                    if (typeof closeSidebar === 'function') {
                        closeSidebar();
                    }
                    if (notificationsDropdown) {
                        notificationsDropdown.classList.add('invisible', 'opacity-0', 'translate-y-2');
                    }
                    if (profileDropdown) {
                        profileDropdown.classList.add('invisible', 'opacity-0', 'translate-y-2');
                    }
                    expandSearch();
                }
            });
        }

        // Collapse search on Escape key
        if (mobileSearchInputInline) {
            mobileSearchInputInline.addEventListener('keydown', function(e) {
                if (e.key === 'Escape') {
                    collapseSearch();
                }
            });
        }

        // Notifications dropdown
        function toggleNotifications(e) {
            if (e) {
                e.preventDefault();
                e.stopPropagation();
            }

            console.log('Notifications toggle clicked');

            // Close search, sidebar and profile when opening notifications
            collapseSearch();
            if (typeof closeSidebar === 'function') {
                closeSidebar();
            }
            if (profileDropdown) {
                profileDropdown.classList.add('invisible', 'opacity-0', 'translate-y-2');
            }

            // Toggle notifications
            if (notificationsDropdown) {
                const isVisible = !notificationsDropdown.classList.contains('invisible');
                if (isVisible) {
                    notificationsDropdown.classList.add('invisible', 'opacity-0', 'translate-y-2');
                } else {
                    notificationsDropdown.classList.remove('invisible', 'opacity-0', 'translate-y-2');
                }
            }
        }

        if (notificationsToggle) {
            notificationsToggle.addEventListener('click', toggleNotifications);
        }

        // Profile dropdown
        function toggleProfile(e) {
            if (e) {
                e.preventDefault();
                e.stopPropagation();
            }

            console.log('Profile toggle clicked');

            // Close search, sidebar and notifications when opening profile
            collapseSearch();
            if (typeof closeSidebar === 'function') {
                closeSidebar();
            }
            if (notificationsDropdown) {
                notificationsDropdown.classList.add('invisible', 'opacity-0', 'translate-y-2');
            }

            // Toggle profile
            if (profileDropdown) {
                const isVisible = !profileDropdown.classList.contains('invisible');
                if (isVisible) {
                    profileDropdown.classList.add('invisible', 'opacity-0', 'translate-y-2');
                } else {
                    profileDropdown.classList.remove('invisible', 'opacity-0', 'translate-y-2');
                }
            }
        }

        if (profileToggle) {
            profileToggle.addEventListener('click', toggleProfile);
        }

        // Close dropdowns when clicking outside
        document.addEventListener('click', function(e) {
            // Close notifications
            if (notificationsDropdown && notificationsToggle && !notificationsToggle.contains(e.target) && !notificationsDropdown.contains(e.target)) {
                notificationsDropdown.classList.add('invisible', 'opacity-0', 'translate-y-2');
            }

            // Close profile
            if (profileDropdown && profileToggle && !profileToggle.contains(e.target) && !profileDropdown.contains(e.target)) {
                profileDropdown.classList.add('invisible', 'opacity-0', 'translate-y-2');
            }

            // Close mobile search
            if (isSearchExpanded && mobileSearchContainer && !mobileSearchContainer.contains(e.target)) {
                collapseSearch();
            }
        });

        // Profile modal function
        window.showProfileModal = function() {
            console.log('Show profile modal called');
            if (typeof showModal === 'function') {
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

                            if (typeof showToast === 'function') {
                                showToast(response.message, 'success');
                            }
                            if (typeof closeModal === 'function') {
                                closeModal();
                            }
                            setTimeout(() => location.reload(), 1000);
                        } catch (error) {
                            if (typeof showToast === 'function') {
                                showToast(error.message, 'error');
                            }
                        }
                    }
                });
            } else {
                console.error('showModal function not found');
            }
        };

        // Settings function
        window.showSettings = function() {
            // Close sidebar
            if (typeof closeSidebar === 'function') {
                closeSidebar();
            }
            // Close profile dropdown
            if (profileDropdown) {
                profileDropdown.classList.add('invisible', 'opacity-0', 'translate-y-2');
            }
            if (typeof showToast === 'function') {
                showToast('Settings coming soon', 'info');
            }
        };
    });
})();
</script>
