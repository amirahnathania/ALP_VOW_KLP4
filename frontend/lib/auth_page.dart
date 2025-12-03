// auth_page.dart
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'services/api_service.dart';
import 'home_page.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Controller untuk form Daftar
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  // Controller untuk form Masuk
  final TextEditingController _loginEmailController = TextEditingController();
  final TextEditingController _loginPasswordController =
      TextEditingController();

  // State variables
  bool _isLoading = false;
  bool _showPassword = false;
  bool _showConfirmPassword = false;
  bool _showLoginPassword = false;

  // Google Sign-In
  final GoogleSignIn _googleSignIn = GoogleSignIn(scopes: ['email', 'profile']);

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  //  FUNGSI REGISTRASI BIASA
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

  //  FUNGSI LOGIN BIASA
  Future<void> _handleLogin() async {
    if (!_isValidEmail(_loginEmailController.text)) {
      _showError('Email tidak valid');
      return;
    }

    if (_loginPasswordController.text.isEmpty) {
      _showError('Kata sandi harus diisi');
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Panggil API login
      final response = await ApiService.login(
        email: _loginEmailController.text,
        password: _loginPasswordController.text,
      );

      // Simpan token dan user data
      final token = response['token'];
      final user = response['user'];

      // Navigasi ke HomePage
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => HomePage(user: user, token: token),
        ),
      );
    } catch (error) {
      _showError('Login gagal: $error');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  //  FUNGSI GOOGLE LOGIN
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

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => HomePage(user: user, token: token),
        ),
      );
    } catch (error) {
      print('Google Login Error: $error');
      _showError('Login dengan Google gagal: $error');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  //  HELPER FUNCTIONS
  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
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

  // ================== WIDGET BUILDERS ==================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Background image
          Positioned.fill(
            child: Image.asset("assets/BG_Desa_Sengka.jpeg", fit: BoxFit.cover),
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
                height: 180, // ← TAMBAHKAN INI (dari 100 jadi 140)
                width: MediaQuery.of(context).size.width * 0.9,
                child: Image.asset('assets/logo.png', fit: BoxFit.contain),
              ),

              const SizedBox(height: 8),

              // Container utama
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(40),
                    ),
                  ),
                  child: Column(
                    children: [
                      // Tab bar
                      TabBar(
                        controller: _tabController,
                        labelColor: const Color(0xFF4A3F2C),
                        unselectedLabelColor: Colors.brown[300],
                        indicatorColor: const Color(0xFF4A3F2C),
                        labelStyle: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                        tabs: const [
                          Tab(text: "Daftar"),
                          Tab(text: "Masuk"),
                        ],
                      ),

                      const SizedBox(height: 25),

                      // Tab content
                      Expanded(
                        child: TabBarView(
                          controller: _tabController,
                          children: [
                            SingleChildScrollView(child: buildRegisterForm()),
                            SingleChildScrollView(child: buildLoginForm()),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  //  FORM DAFTAR
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
          hint: "nama@ketua.ac.id/nama@gapoktan.ac.id",
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

        // Atau masuk dengan Google
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Text("atau", style: TextStyle(color: Colors.black54)),
          ],
        ),
        const SizedBox(height: 12),
        _buildGoogleButton(),

        const SizedBox(height: 40),
      ],
    );
  }

  //  FORM MASUK
  Widget buildLoginForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel("Email"),
        _buildTextField(
          controller: _loginEmailController,
          hint: "nama@ketua.ac.id/nama@gapoktan.ac.id",
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

        const SizedBox(height: 30),
        Center(
          child: _buildMainButton(
            text: "Masuk",
            onPressed: _isLoading ? null : _handleLogin,
            isLoading: _isLoading,
          ),
        ),

        const SizedBox(height: 20),

        // Atau masuk dengan Google
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Text("atau", style: TextStyle(color: Colors.black54)),
          ],
        ),
        const SizedBox(height: 12),
        _buildGoogleButton(),

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
          contentPadding: const EdgeInsets.symmetric(
            vertical: 16,
            horizontal: 20,
          ),
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
          contentPadding: const EdgeInsets.symmetric(
            vertical: 16,
            horizontal: 20,
          ),
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
        backgroundColor: const Color(0xFF8BC784),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
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

  Widget _buildGoogleButton() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: OutlinedButton(
        onPressed: _isLoading ? null : _handleGoogleSignIn,
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: Colors.grey.shade300),
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          backgroundColor: Colors.white,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 26,
              height: 26,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(13),
                border: Border.all(color: Colors.red, width: 2),
              ),
              child: const Center(
                child: Text(
                  "G",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              "Masuk lewat Google",
              style: TextStyle(fontSize: 16, color: Colors.black87),
            ),
          ],
        ),
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
