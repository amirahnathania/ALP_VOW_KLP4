<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta name="csrf-token" content="{{ csrf_token() }}">
    <title>@yield('title', 'Admin') - BelajarTani Admin</title>

    <!-- Fonts -->
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&display=swap" rel="stylesheet">

    <!-- Styles -->
    @vite(['resources/css/app.css', 'resources/js/app.js'])

    <!-- Chart.js -->
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>

    @stack('styles')
</head>

<body class="font-sans antialiased bg-gray-50">
    <div class="flex min-h-screen">
        <!-- Sidebar -->
        @include('admin.partials.sidebar')

        <!-- Main Content -->
        <div class="flex-1 ml-64">
            <!-- Header -->
            @include('admin.partials.header')

            <!-- Page Content -->
            <main class="p-6">
                @yield('content')
            </main>
        </div>
    </div>

    <!-- Toast Container -->
    <div id="toast-container" class="fixed top-4 right-4 z-50 space-y-2"></div>

    <!-- Modal Container -->
    <div id="modal-container"></div>

    <!-- Drawer Container -->
    <div id="drawer-container"></div>

    <!-- Global Scripts -->
    <script>
        // CSRF Token for AJAX
        const csrfToken = document.querySelector('meta[name="csrf-token"]').content;

        // Show toast notification
        function showToast(message, type = 'info', duration = 3000) {
            const container = document.getElementById('toast-container');
            const toast = document.createElement('div');

            const icons = {
                success: '<svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7"></path></svg>',
                error: '<svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12"></path></svg>',
                warning: '<svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-3L13.732 4c-.77-1.333-2.694-1.333-3.464 0L3.34 16c-.77 1.333.192 3 1.732 3z"></path></svg>',
                info: '<svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13 16h-1v-4h-1m1-4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z"></path></svg>'
            };

            const colors = {
                success: 'bg-emerald-500',
                error: 'bg-red-500',
                warning: 'bg-amber-500',
                info: 'bg-blue-500'
            };

            toast.className =
                `toast ${colors[type]} text-white px-4 py-3 rounded-lg shadow-lg flex items-center gap-3 min-w-[300px]`;
            toast.innerHTML = `
                ${icons[type]}
                <span class="flex-1">${message}</span>
                <button onclick="this.parentElement.remove()" class="opacity-70 hover:opacity-100">
                    <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12"></path>
                    </svg>
                </button>
            `;

            container.appendChild(toast);

            setTimeout(() => {
                toast.classList.add('toast-exit');
                setTimeout(() => toast.remove(), 300);
            }, duration);
        }

        // Show modal
        function showModal(options) {
            const container = document.getElementById('modal-container');
            const modal = document.createElement('div');
            modal.className = 'modal-backdrop';
            modal.id = 'active-modal';

            const sizes = {
                sm: 'max-w-md',
                md: 'max-w-lg',
                lg: 'max-w-2xl',
                xl: 'max-w-4xl'
            };

            modal.innerHTML = `
                <div class="modal ${sizes[options.size || 'md']}">
                    <div class="modal-header">
                        <h3 class="modal-title">${options.title || 'Modal'}</h3>
                        <button onclick="closeModal()" class="text-gray-400 hover:text-gray-600">
                            <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12"></path>
                            </svg>
                        </button>
                    </div>
                    <div class="modal-body">${options.content || ''}</div>
                    ${options.hideFooter ? '' : `
                        <div class="modal-footer">
                            <button onclick="closeModal()" class="btn btn-secondary">${options.cancelText || 'Batal'}</button>
                            ${options.onConfirm ? `<button onclick="(${options.onConfirm.toString()})()" class="btn btn-primary">${options.confirmText || 'OK'}</button>` : ''}
                        </div>
                        `}
                </div>
            `;

            modal.querySelector('.modal-backdrop')?.addEventListener('click', (e) => {
                if (e.target === modal) closeModal();
            });

            container.innerHTML = '';
            container.appendChild(modal);
        }

        // Close modal
        function closeModal() {
            const modal = document.getElementById('active-modal');
            if (modal) {
                modal.classList.add('modal-exit');
                setTimeout(() => modal.remove(), 200);
            }
        }

        // Confirm dialog
        function confirmDialog(message, onConfirm) {
            showModal({
                title: 'Konfirmasi',
                size: 'sm',
                content: `<p class="text-gray-600">${message}</p>`,
                confirmText: 'Ya, Lanjutkan',
                onConfirm: onConfirm
            });
        }

        // Show drawer
        function showDrawer(options) {
            const container = document.getElementById('drawer-container');
            const drawer = document.createElement('div');
            drawer.id = 'active-drawer';

            drawer.innerHTML = `
                <div class="drawer-backdrop" onclick="closeDrawer()"></div>
                <div class="drawer">
                    <div class="drawer-header">
                        <h3 class="text-lg font-semibold">${options.title || 'Drawer'}</h3>
                        <button onclick="closeDrawer()" class="text-gray-400 hover:text-gray-600">
                            <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12"></path>
                            </svg>
                        </button>
                    </div>
                    <div class="drawer-body">${options.content || ''}</div>
                    ${options.footer ? `<div class="drawer-footer">${options.footer}</div>` : ''}
                </div>
            `;

            container.innerHTML = '';
            container.appendChild(drawer);
        }

        // Close drawer
        function closeDrawer() {
            const drawer = document.getElementById('active-drawer');
            if (drawer) drawer.remove();
        }

        // Fetch API helper
        async function fetchApi(url, options = {}) {
            const defaultOptions = {
                headers: {
                    'Content-Type': 'application/json',
                    'X-CSRF-TOKEN': csrfToken,
                    'Accept': 'application/json'
                }
            };

            const response = await fetch(url, {
                ...defaultOptions,
                ...options
            });
            const data = await response.json();

            if (!response.ok) {
                throw new Error(data.message || 'Request failed');
            }

            return data;
        }
    </script>

    @if (session('success'))
        <script>
            document.addEventListener('DOMContentLoaded', function() {
                showToast('{{ session('success') }}', 'success');
            });
        </script>
    @endif

    @if (session('error'))
        <script>
            document.addEventListener('DOMContentLoaded', function() {
                showToast('{{ session('error') }}', 'error');
            });
        </script>
    @endif

    @stack('scripts')
</body>

</html>
