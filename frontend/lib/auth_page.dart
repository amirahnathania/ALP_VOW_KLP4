import 'package:flutter/material.dart';
import 'services/api_service.dart';
import 'main_layout.dart';
import 'home_gapoktan.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  // Controller untuk form Masuk
  final TextEditingController _loginEmailController = TextEditingController();
  final TextEditingController _loginPasswordController = TextEditingController();
  
  // State variables
  bool _isLoading = false;
  bool _showLoginPassword = false;

  // Fungsi untuk menentukan role berdasarkan email
  String _getUserRole(String email) {
    if (email.endsWith('@ketua.ac.id')) {
      return 'ketua';
    } else if (email.endsWith('@gapoktan.ac.id')) {
      return 'gapoktan';
    }
    return 'unknown';
  }

  // ================== FUNGSI LOGIN BIASA ==================
  Future<void> _handleLogin() async {
    final email = _loginEmailController.text.trim();
    
    if (!_isValidEmail(email)) {
      _showError('Email tidak valid');
      return;
    }
    
    // Validasi domain email
    final userRole = _getUserRole(email);
    if (userRole == 'unknown') {
      _showError('Email harus menggunakan domain @ketua.ac.id atau @gapoktan.ac.id');
      return;
    }
    
    if (_loginPasswordController.text.isEmpty) {
      _showError('Password harus diisi');
      return;
    }
    
    setState(() => _isLoading = true);
    
    try {
      final res = await ApiService.login(
        email: email,
        password: _loginPasswordController.text,
      );

      if (res['success'] == true) {
        // Tambahkan role ke data user
        final userData = Map<String, dynamic>.from(res['data']);
        userData['role'] = userRole;
        
        // Navigasi berdasarkan role
        if (userRole == 'ketua') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => MainLayoutScreen(
                user: userData,
                token: res['token'],
              ),
            ),
          );
        } else if (userRole == 'gapoktan') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => HomePage(
                user: userData,
                token: res['token'],
              ),
            ),
          );
        }
      } else {
        _showError(res['message'] ?? "Login gagal");
      }
    } catch (e) {
      _showError("Login gagal: $e");
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  // ================== HELPER FUNCTIONS ==================
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
                height: 180, 
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
                      const Text(
                        "Selamat Datang",
                        style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF4A3F2C),
                        ),
                      ),
                      
                      const SizedBox(height: 8),
                      
                      const Text(
                        "Silakan masuk dengan akun Anda",
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),

                      const SizedBox(height: 25),

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
          ),
        ],
      ),
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
          onChanged: (value) {
            // Opsional: Berikan visual feedback untuk domain yang valid
            final email = value.trim();
            if (email.isNotEmpty) {
              final role = _getUserRole(email);
              if (role != 'unknown') {
                // Bisa tambahkan indikator visual di sini
              }
            }
          },
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

        // Informasi domain email
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: const Row(
            children: [
              Icon(Icons.info_outline, color: Color(0xFF8BC784), size: 20),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  "Gunakan email dengan domain:\n• @ketua.ac.id untuk Ketua Kelompok Tani\n• @gapoktan.ac.id untuk Gabungan Kelompok Tani",
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
              ),
            ],
          ),
        ),

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
    ValueChanged<String>? onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        onChanged: onChanged,
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

  @override
  void dispose() {
    _loginEmailController.dispose();
    _loginPasswordController.dispose();
    super.dispose();
  }
}