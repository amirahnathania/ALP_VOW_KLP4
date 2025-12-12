import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'services/api_service.dart';
import 'main_layout.dart';
import 'home_gapoktan.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  // Controller untuk form Daftar
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  
  // Controller untuk form Masuk
  final TextEditingController _loginEmailController = TextEditingController();
  final TextEditingController _loginPasswordController = TextEditingController();
  
  // State variables
  bool _isLoading = false;
  bool _showPassword = false;
  bool _showConfirmPassword = false;
  bool _showLoginPassword = false;
  
  // Google Sign-In
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
  );

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 1, vsync: this);
  }

  // ================== FUNGSI REGISTRASI BIASA ==================
  Future<void> _handleRegister() async {
    // Validasi form
    if (_nameController.text.isEmpty) {
      _showError('Nama lengkap harus diisi');
      return;
    }
    
    if (!_isValidEmail(_emailController.text)) {
      _showError('Email tidak valid');
      return;
    }
    
    if (_passwordController.text.length < 8) {
      _showError('Kata sandi minimal 8 karakter');
      return;
    }
    
    if (_passwordController.text != _confirmPasswordController.text) {
      _showError('Konfirmasi kata sandi tidak cocok');
      return;
    }
    
    setState(() => _isLoading = true);
    
    try {
      // Panggil API registrasi
      await ApiService.register(
        name: _nameController.text,
        email: _emailController.text,
        password: _passwordController.text,
      );
      
      // Berhasil registrasi
      _showSuccess('Registrasi berhasil! Silakan login');
      
      // Clear form
      _nameController.clear();
      _emailController.clear();
      _passwordController.clear();
      _confirmPasswordController.clear();
      
      // Switch ke tab Login
      _tabController.animateTo(1);
      
    } catch (error) {
      _showError('Registrasi gagal: $error');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // ================== FUNGSI LOGIN BIASA ==================
  Future<void> _handleLogin() async {
    // Langsung gunakan mock data tanpa validasi ketat
    final email = _loginEmailController.text.trim().toLowerCase();
    final password = _loginPasswordController.text.trim();
    
    if (email.isEmpty) {
      _showError('Email harus diisi');
      return;
    }
    
    if (password.isEmpty) {
      _showError('Kata sandi harus diisi');
      return;
    }
    
    setState(() => _isLoading = true);
    
    try {
      Map<String, dynamic> user;
      String token;
      
      // Mock data berdasarkan email - langsung tanpa try-catch API
      if (email.contains('@ketua.ac.id')) {
        user = {
          'name': 'Demo Ketua',
          'email': email,
          'jabatan': 'Ketua',
          'role': 'ketua',
          'awal_jabatan': '2022-01-01',
          'akhir_jabatan': '2026-01-01',
          'photo': 'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?auto=format&fit=crop&w=600&q=60',
        };
        token = 'mock-ketua-token-${DateTime.now().millisecondsSinceEpoch}';
        
        // Delay sedikit untuk simulasi loading
        await Future.delayed(const Duration(milliseconds: 500));
        
        // Tentukan role dan navigasi
        final role = _getRoleFromEmail(user['email'] ?? '');
        
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => _getHomePageForRole(role, user, token),
          ),
        );
      } else if (email.contains('@gapoktang.ac.id')) {
        user = {
          'name': 'Demo Gapoktan',
          'email': email,
          'jabatan': 'Gapoktan',
          'role': 'gapoktan',
          'awal_jabatan': '2024-01-01',
          'akhir_jabatan': '2028-01-01',
          'lama_jabatan': '11 bulan',
          'photo': 'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?auto=format&fit=crop&w=600&q=60',
        };
        token = 'mock-gapoktan-token-${DateTime.now().millisecondsSinceEpoch}';
        
        // Delay sedikit untuk simulasi loading
        await Future.delayed(const Duration(milliseconds: 500));
        
        // Tentukan role dan navigasi
        final role = _getRoleFromEmail(user['email'] ?? '');
        
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => _getHomePageForRole(role, user, token),
          ),
        );
      } else {
        _showError('Email harus menggunakan domain @ketua.ac.id atau @gapoktang.ac.id');
      }
      
    } catch (error) {
      _showError('Login gagal: $error');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // ================== FUNGSI GOOGLE LOGIN ==================
  // ignore: unused_element
  Future<void> _handleGoogleSignIn() async {
    setState(() => _isLoading = true);
    
    try {
      // 1. Login dengan Google
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      
      if (googleUser == null) {
        throw Exception('User membatalkan login');
      }
      
      // 2. Dapatkan authentication data
      final GoogleSignInAuthentication googleAuth = 
          await googleUser.authentication;
      
      // 3. Siapkan data untuk dikirim ke Laravel
      final googleData = {
        'id': googleUser.id,
        'name': googleUser.displayName ?? 'User',
        'email': googleUser.email,
        'photo': googleUser.photoUrl,
        'access_token': googleAuth.accessToken,
        'id_token': googleAuth.idToken,
      };
      
      // 4. Kirim ke Laravel API
      final apiResponse = await ApiService.loginWithGoogle(googleData);
      
      // 5. Simpan token dan navigasi
      final token = apiResponse['token'];
      final user = apiResponse['user'];
      
      // Tentukan role berdasarkan email
      final role = _getRoleFromEmail(user['email'] ?? googleUser.email);
      
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => _getHomePageForRole(role, user, token),
        ),
      );
      
    } catch (error) {
      print('Google Login Error: $error');
      _showError('Login dengan Google gagal: $error');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // ================== HELPER FUNCTIONS ==================
  bool _isValidEmail(String email) {
    // Lebih permisif untuk email dengan format @ketua.ac.id dan @gapoktang.ac.id
    if (email.isEmpty) return false;
    return email.contains('@') && email.contains('.');
  }
  
  String _getRoleFromEmail(String email) {
    if (email.toLowerCase().contains('@ketua.ac.id')) {
      return 'ketua';
    } else if (email.toLowerCase().contains('@gapoktang.ac.id')) {
      return 'gapoktan';
    }
    return 'unknown';
  }
  
  Widget _getHomePageForRole(String role, Map<String, dynamic> user, String token) {
    if (role == 'ketua') {
      return MainLayoutScreen(user: user, token: token);
    } else if (role == 'gapoktan') {
      return HomePage(user: user, token: token);
    }
    // Default ke ketua jika role tidak dikenali
    return MainLayoutScreen(user: user, token: token);
  }
  
  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }
  
  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFF8BC784),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  // ================== LUPA SANDI ==================
  void _showForgotPasswordDialog() {
    final TextEditingController emailController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: const [
              Icon(Icons.lock_reset, color: Color(0xFF62903A)),
              SizedBox(width: 10),
              Text(
                'Lupa Sandi',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Masukkan email Anda untuk mendapatkan link reset kata sandi.',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.email, color: Colors.brown),
                  hintText: "Email",
                  filled: true,
                  fillColor: Colors.grey[100],
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 16,
                    horizontal: 20,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(
                      color: Color(0xFF62903A),
                      width: 2,
                    ),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Batal',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 16,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                if (emailController.text.isEmpty) {
                  Navigator.pop(context);
                  _showError('Email harus diisi');
                  return;
                }
                
                if (!_isValidEmail(emailController.text)) {
                  Navigator.pop(context);
                  _showError('Email tidak valid');
                  return;
                }
                
                // Simulasi kirim email reset password
                Navigator.pop(context);
                _showSuccess(
                  'Link reset kata sandi telah dikirim ke ${emailController.text}',
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF62903A),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
              child: const Text(
                'Kirim',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // ================== WIDGET BUILDERS ==================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Background image
          Positioned.fill(
            child: Image.asset(
              "assets/BG_Desa_Sengka.jpeg",
              fit: BoxFit.cover,
            ),
          ),

          // Gradient overlay
          Container(
            height: 260,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.white.withOpacity(0.9),
                  Colors.white.withOpacity(0.8),
                  Colors.white.withOpacity(0.0),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),

          // Content
          Column(
            children: [
              const SizedBox(height: 40),
              Container(
                height: 250,
                width: MediaQuery.of(context).size.width * 0.9,
                child: Image.asset(
                  'assets/logo.png',
                  fit: BoxFit.contain,
                ),
              ),

              const SizedBox(height: 8),

              // Container utama
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(40)),
                  ),
                  child: Column(
                    children: [
                      // Title
                      const Text(
                        "Selamat Datang",
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF4A3F2C),
                        ),
                      ),

                      const SizedBox(height: 25),

                      // Login form content
                      Expanded(
                        child: SingleChildScrollView(
                          child: buildLoginForm(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  // ================== FORM DAFTAR ==================
  Widget buildRegisterForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel("Nama Lengkap"),
        _buildTextField(
          controller: _nameController,
          hint: "Masukkan nama lengkap",
          icon: Icons.person,
        ),

        _buildLabel("Email"),
        _buildTextField(
          controller: _emailController,
          hint: "Masukkan Email",
          icon: Icons.email,
          keyboardType: TextInputType.emailAddress,
        ),

        _buildLabel("Kata Sandi"),
        _buildPasswordField(
          controller: _passwordController,
          hint: "Minimal 8 karakter",
          isPassword: true,
          showPassword: _showPassword,
          onToggleVisibility: () {
            setState(() => _showPassword = !_showPassword);
          },
        ),

        _buildLabel("Konfirmasi Kata Sandi"),
        _buildPasswordField(
          controller: _confirmPasswordController,
          hint: "Ulangi kata sandi",
          isPassword: true,
          showPassword: _showConfirmPassword,
          onToggleVisibility: () {
            setState(() => _showConfirmPassword = !_showConfirmPassword);
          },
        ),

        const SizedBox(height: 30),
        Center(
          child: _buildMainButton(
            text: "Daftar",
            onPressed: _isLoading ? null : _handleRegister,
            isLoading: _isLoading,
          ),
        ),

        const SizedBox(height: 20),

        const SizedBox(height: 40),
      ],
    );
  }

  // ================== FORM MASUK ==================
  Widget buildLoginForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel("Email"),
        _buildTextField(
          controller: _loginEmailController,
          hint: "Masukkan Email",
          icon: Icons.email,
          keyboardType: TextInputType.emailAddress,
        ),

        _buildLabel("Kata Sandi"),
        _buildPasswordField(
          controller: _loginPasswordController,
          hint: "Masukkan kata sandi",
          isPassword: true,
          showPassword: _showLoginPassword,
          onToggleVisibility: () {
            setState(() => _showLoginPassword = !_showLoginPassword);
          },
        ),

        // Lupa Sandi
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: _showForgotPasswordDialog,
            child: const Text(
              'Lupa Sandi?',
              style: TextStyle(
                color: Color(0xFF62903A),
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),

        const SizedBox(height: 20),
        Center(
          child: _buildMainButton(
            text: "Masuk",
            onPressed: _isLoading ? null : _handleLogin,
            isLoading: _isLoading,
          ),
        ),

        const SizedBox(height: 20),

        const SizedBox(height: 40),
      ],
    );
  }

  // ================== WIDGET COMPONENTS ==================
  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, top: 16),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: Colors.brown),
          hintText: hint,
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Colors.grey.shade400),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Color(0xFF8BC784), width: 2),
          ),
        ),
      ),
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String hint,
    required bool isPassword,
    required bool showPassword,
    required VoidCallback onToggleVisibility,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: TextField(
        controller: controller,
        obscureText: isPassword && !showPassword,
        decoration: InputDecoration(
          prefixIcon: const Icon(Icons.lock, color: Colors.brown),
          hintText: hint,
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Colors.grey.shade400),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Color(0xFF8BC784), width: 2),
          ),
          suffixIcon: IconButton(
            icon: Icon(
              showPassword ? Icons.visibility_off : Icons.visibility,
              color: Colors.grey,
            ),
            onPressed: onToggleVisibility,
          ),
        ),
      ),
    );
  }

  Widget _buildMainButton({
    required String text,
    required VoidCallback? onPressed,
    required bool isLoading,
  }) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF4C7B0F),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        elevation: 0,
      ),
      child: isLoading
          ? const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 2,
              ),
            )
          : Text(
              text,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _loginEmailController.dispose();
    _loginPasswordController.dispose();
    _tabController.dispose();
    super.dispose();
  }
}