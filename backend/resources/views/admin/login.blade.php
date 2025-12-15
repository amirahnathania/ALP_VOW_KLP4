<!DOCTYPE html>
<html lang="id">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta name="csrf-token" content="{{ csrf_token() }}">
    <title>Login - Admin BelajarTani</title>
    <!-- Fonts -->
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <!-- FontAwesome -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css"
        integrity="sha512-..." crossorigin="anonymous" referrerpolicy="no-referrer" />
    @vite(['resources/css/app.css', 'resources/js/app.js'])
</head>

<body
    class="min-h-screen bg-gradient-to-br from-[#0b1319] via-[#1a2530] to-[#0b1319] flex items-center justify-center p-4">
    <div class="w-full max-w-md">
        <!-- Logo -->
        <div class="text-center mb-8">
            <img src="/images/logo.png" alt="BelajarTani Logo"
                class="mx-auto w-16 h-16 rounded-2xl mb-4 shadow-lg object-contain bg-[#d1d1d1] p-2">
            <h1 class="text-2xl font-bold text-white">BelajarTani</h1>
            <p class="text-[#8b8e92] mt-2">Admin Dashboard</p>
        </div>
        <!-- Login Card -->
        <div class="bg-white rounded-2xl shadow-xl p-8 animate-slide-in-up">
            <div class="text-center mb-6">
                <h2 class="text-xl font-semibold text-gray-900">Selamat Datang Kembali</h2>
                <p class="text-gray-500 text-sm mt-1">Masuk ke akun admin Anda</p>
            </div>
            @if (session('success'))
                <div class="mb-4 p-4 bg-green-50 border border-green-200 rounded-lg flex items-center gap-3">
                    <i class="fa-solid fa-circle-check text-green-500 w-5 h-5"></i>
                    <span class="text-sm text-green-700">{{ session('success') }}</span>
                </div>
            @endif
            @if (session('error'))
                <div class="mb-4 p-4 bg-red-50 border border-red-200 rounded-lg flex items-center gap-3">
                    <i class="fa-solid fa-circle-exclamation text-red-500 w-5 h-5"></i>
                    <span class="text-sm text-red-700">{{ session('error') }}</span>
                </div>
            @endif
            <form action="{{ route('admin.login.submit') }}" method="POST" class="space-y-5">
                @csrf
                <!-- Email -->
                <div>
                    <label for="email" class="form-label">Email</label>
                    <input type="email" id="email" name="email" value="{{ old('email') }}"
                        class="form-input @error('email') error @enderror" placeholder="example@gmail.com" required
                        autofocus>
                    @error('email')
                        <p class="form-error">{{ $message }}</p>
                    @enderror
                </div>
                <!-- Password -->
                <div>
                    <label for="password" class="form-label">Password</label>
                    <div class="relative">
                        <input type="password" id="password" name="password"
                            class="form-input pr-10 @error('password') error @enderror" placeholder="••••••••" required>
                        <button type="button" onclick="togglePassword()"
                            class="absolute right-3 top-1/2 -translate-y-1/2 text-gray-400 hover:text-gray-600 focus:outline-none"
                            tabindex="-1">
                            <i id="eye-icon" class="fa-solid fa-eye" style="display: block;"></i>
                            <i id="eye-off-icon" class="fa-solid fa-eye-slash" style="display: none;"></i>
                        </button>
                    </div>
                    @error('password')
                        <p class="form-error">{{ $message }}</p>
                    @enderror
                </div>
                <!-- Remember Me -->
                <div class="flex items-center justify-between">
                    <label class="flex items-center gap-2 cursor-pointer">
                        <input type="checkbox" name="remember" class="checkbox">
                        <span class="text-sm text-gray-600">Ingat saya</span>
                    </label>
                    <a href="#" class="text-sm text-[#0b1319] hover:text-[#8b8e92] font-medium">Lupa password?</a>
                </div>
                <!-- Submit Button -->
                <button type="submit" class="btn btn-primary w-full py-3 flex items-center justify-center gap-2">
                    <span class="align-middle">Masuk</span>
                </button>
            </form>
        </div>
        <!-- Footer -->
        <p class="text-center text-gray-500 text-sm mt-8">
            &copy; {{ date('Y') }} BelajarTani. All rights reserved.
        </p>
    </div>
    <script>
        function togglePassword() {
            const input = document.getElementById('password');
            const eyeIcon = document.getElementById('eye-icon');
            const eyeOffIcon = document.getElementById('eye-off-icon');
            if (input.type === 'password') {
                input.type = 'text';
                eyeIcon.style.display = 'none';
                eyeOffIcon.style.display = 'block';
            } else {
                input.type = 'password';
                eyeIcon.style.display = 'block';
                eyeOffIcon.style.display = 'none';
            }
        }
    </script>
</body>

</html>
