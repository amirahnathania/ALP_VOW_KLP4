<!-- Sidebar -->
<aside id="sidebar"
    class="sidebar fixed left-0 top-0 bottom-0 w-64 bg-[#0b1319] text-white z-50 overflow-y-auto transition-transform duration-300 transform -translate-x-full lg:translate-x-0">
    <!-- Logo -->
    <div class="h-16 flex items-center justify-between px-4 border-b border-gray-700/50">
        <a href="{{ route('admin.dashboard') }}" class="flex items-center gap-3">
            <img src="/images/logo.png" alt="BelajarTani Logo" class="w-8 h-8 rounded-lg bg-[#d1d1d1] object-contain p-1">
            <span class="text-lg font-semibold">BelajarTani</span>
        </a>
        <button id="sidebar-close" class="lg:hidden text-gray-400 hover:text-white">
            <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12"></path>
            </svg>
        </button>
    </div>

    <!-- Search -->
    <div class="p-4">
        <div class="relative">
            <input type="text" placeholder="Search"
                class="w-full bg-[#1a2530] border-none rounded-lg pl-10 pr-4 py-2 text-sm text-gray-300 placeholder-gray-500 focus:ring-2 focus:ring-[#8b8e92]/50 focus:outline-none">
            <svg class="w-4 h-4 absolute left-3 top-1/2 -translate-y-1/2 text-gray-500" fill="none"
                stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                    d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z"></path>
            </svg>
        </div>
    </div>

    <!-- Navigation -->
    <nav class="px-3 pb-4">
        <!-- Main Menu -->
        <div class="mb-6">
            <a href="{{ route('admin.dashboard') }}"
                class="sidebar-link {{ request()->routeIs('admin.dashboard*') ? 'active' : '' }}">
                <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                        d="M4 5a1 1 0 011-1h14a1 1 0 011 1v2a1 1 0 01-1 1H5a1 1 0 01-1-1V5zM4 13a1 1 0 011-1h6a1 1 0 011 1v6a1 1 0 01-1 1H5a1 1 0 01-1-1v-6zM16 13a1 1 0 011-1h2a1 1 0 011 1v6a1 1 0 01-1 1h-2a1 1 0 01-1-1v-6z">
                    </path>
                </svg>
                <span>Dashboard</span>
            </a>
        </div>

        <!-- Data Management -->
        <div class="mb-6">
            <p class="px-3 text-xs font-semibold text-gray-500 uppercase tracking-wider mb-3">Data Management</p>

            <a href="{{ route('admin.users.index') }}"
                class="sidebar-link {{ request()->routeIs('admin.users*') ? 'active' : '' }}">
                <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                        d="M12 4.354a4 4 0 110 5.292M15 21H3v-1a6 6 0 0112 0v1zm0 0h6v-1a6 6 0 00-9-5.197M13 7a4 4 0 11-8 0 4 4 0 018 0z">
                    </path>
                </svg>
                <span>Users</span>
            </a>

            <a href="{{ route('admin.kegiatan.index') }}"
                class="sidebar-link {{ request()->routeIs('admin.kegiatan*') ? 'active' : '' }}">
                <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                        d="M8 7V3m8 4V3m-9 8h10M5 21h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v12a2 2 0 002 2z">
                    </path>
                </svg>
                <span>Kegiatan</span>
            </a>
        </div>

        <!-- Settings -->
        <div class="mb-6">
            <p class="px-3 text-xs font-semibold text-gray-500 uppercase tracking-wider mb-3">Settings</p>

            @if (Auth::guard('admin')->user()->isSuperAdmin())
                <a href="{{ route('admin.admins.index') }}"
                    class="sidebar-link {{ request()->routeIs('admin.admins*') ? 'active' : '' }}">
                    <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                            d="M9 12l2 2 4-4m5.618-4.016A11.955 11.955 0 0112 2.944a11.955 11.955 0 01-8.618 3.04A12.02 12.02 0 003 9c0 5.591 3.824 10.29 9 11.622 5.176-1.332 9-6.03 9-11.622 0-1.042-.133-2.052-.382-3.016z">
                        </path>
                    </svg>
                    <span>Admin Management</span>
                </a>
            @endif

            <a href="#" class="sidebar-link" onclick="showNotifications()">
                <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                        d="M15 17h5l-1.405-1.405A2.032 2.032 0 0118 14.158V11a6.002 6.002 0 00-4-5.659V5a2 2 0 10-4 0v.341C7.67 6.165 6 8.388 6 11v3.159c0 .538-.214 1.055-.595 1.436L4 17h5m6 0v1a3 3 0 11-6 0v-1m6 0H9">
                    </path>
                </svg>
                <span>Notifications</span>
                @php $notifCount = 0; /* Replace with actual notification count */ @endphp
                @if ($notifCount > 0)
                    <span
                        class="ml-auto bg-red-500 text-white text-xs px-2 py-0.5 rounded-full">{{ $notifCount }}</span>
                @endif
            </a>

            <a href="#" class="sidebar-link" onclick="showHelp()">
                <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                        d="M8.228 9c.549-1.165 2.03-2 3.772-2 2.21 0 4 1.343 4 3 0 1.4-1.278 2.575-3.006 2.907-.542.104-.994.54-.994 1.093m0 3h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z">
                    </path>
                </svg>
                <span>Help & Support</span>
            </a>

            <a href="#" class="sidebar-link" onclick="showSettings()">
                <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                        d="M10.325 4.317c.426-1.756 2.924-1.756 3.35 0a1.724 1.724 0 002.573 1.066c1.543-.94 3.31.826 2.37 2.37a1.724 1.724 0 001.065 2.572c1.756.426 1.756 2.924 0 3.35a1.724 1.724 0 00-1.066 2.573c.94 1.543-.826 3.31-2.37 2.37a1.724 1.724 0 00-2.572 1.065c-.426 1.756-2.924 1.756-3.35 0a1.724 1.724 0 00-2.573-1.066c-1.543.94-3.31-.826-2.37-2.37a1.724 1.724 0 00-1.065-2.572c-1.756-.426-1.756-2.924 0-3.35a1.724 1.724 0 001.066-2.573c-.94-1.543.826-3.31 2.37-2.37.996.608 2.296.07 2.572-1.065z">
                    </path>
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                        d="M15 12a3 3 0 11-6 0 3 3 0 016 0z"></path>
                </svg>
                <span>Settings</span>
            </a>
        </div>
    </nav>

    <!-- User Profile -->
    <div class="absolute bottom-0 left-0 right-0 p-4 border-t border-gray-700/50 bg-[#050a0d]">
        <div class="flex items-center gap-3">
            <div class="w-10 h-10 rounded-full bg-[#8b8e92] flex items-center justify-center text-white font-semibold">
                {{ Auth::guard('admin')->user()->initials }}
            </div>
            <div class="flex-1 min-w-0">
                <p class="text-sm font-medium text-white truncate">{{ Auth::guard('admin')->user()->name }}</p>
                <p class="text-xs text-gray-400 truncate">{{ Auth::guard('admin')->user()->email }}</p>
            </div>
            <form action="{{ route('admin.logout') }}" method="POST">
                @csrf
                <button type="submit" class="text-gray-400 hover:text-white" title="Logout">
                    <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                            d="M17 16l4-4m0 0l-4-4m4 4H7m6 4v1a3 3 0 01-3 3H6a3 3 0 01-3-3V7a3 3 0 013-3h4a3 3 0 013 3v1">
                        </path>
                    </svg>
                </button>
            </form>
        </div>
    </div>
</aside>

<!-- Mobile Sidebar Overlay -->
<div id="sidebar-overlay" class="fixed inset-0 bg-black/50 z-40 lg:hidden hidden" onclick="closeSidebar()"></div>

<script>
    function openSidebar() {
        document.getElementById('sidebar').classList.remove('-translate-x-full');
        document.getElementById('sidebar-overlay').classList.remove('hidden');
        document.body.classList.add('overflow-hidden');
    }

    function closeSidebar() {
        document.getElementById('sidebar').classList.add('-translate-x-full');
        document.getElementById('sidebar-overlay').classList.add('hidden');
        document.body.classList.remove('overflow-hidden');
    }

    document.getElementById('sidebar-close')?.addEventListener('click', closeSidebar);

    // Open sidebar on hamburger click
    document.querySelectorAll('.sidebar-hamburger').forEach(btn => {
        btn.addEventListener('click', openSidebar);
    });

    // Hide sidebar on resize to desktop
    window.addEventListener('resize', function() {
        if (window.innerWidth >= 1024) {
            closeSidebar();
        }
    });

    function showNotifications() {
        showToast('No new notifications', 'info');
    }

    function showHelp() {
        showModal({
            title: 'Help & Support',
            content: `
                <div class="space-y-4">
                    <p class="text-gray-600">Butuh bantuan? Hubungi tim support kami:</p>
                    <div class="bg-gray-50 p-4 rounded-lg">
                        <p class="font-medium">Email Support</p>
                        <p class="text-gray-600">support@belajartani.ac.id</p>
                    </div>
                    <div class="bg-gray-50 p-4 rounded-lg">
                        <p class="font-medium">Documentation</p>
                        <p class="text-gray-600">Lihat panduan lengkap di docs.belajartani.ac.id</p>
                    </div>
                </div>
            `,
            showFooter: false,
            size: 'sm'
        });
    }

    function showSettings() {
        showToast('Settings coming soon', 'info');
    }
</script>

<style>
    @media (max-width: 1024px) {
        body.overflow-hidden {
            overflow: hidden !important;
            position: fixed;
            width: 100vw;
        }

        #sidebar {
            z-index: 50;
        }

        #sidebar-overlay {
            z-index: 40;
        }
    }
</style>
