import 'package:flutter/material.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _showPassword = false;
  bool _showConfirmPassword = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Background image
          Positioned.fill(
            child: Container(
              color: const Color(0xFFFAF3E0), // Warna krem sebagai background
            ),
          ),

          // Content
          SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 80),
                
                // Judul BelajarTani
                const Text(
                  "# BelajarTani",
                  style: TextStyle(
                    fontSize: 36,
                    color: Color(0xFF4A2619), // Coklat tua
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.5,
                  ),
                ),

                const SizedBox(height: 40),

                // Tab selector dengan styling khusus
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 40),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Tab Daftar
                      GestureDetector(
                        onTap: () {
                          _tabController.animateTo(0);
                          setState(() {});
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: _tabController.index == 0
                                ? const Color(0xFF7DBF6C) // Hijau jika aktif
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            _tabController.index == 0 ? "**Daftar**" : "Daftar",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: _tabController.index == 0
                                  ? FontWeight.w900
                                  : FontWeight.w400,
                              color: _tabController.index == 0
                                  ? Colors.white
                                  : const Color(0xFF4A2619).withOpacity(0.6),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(width: 20),

                      // Tab Masuk
                      GestureDetector(
                        onTap: () {
                          _tabController.animateTo(1);
                          setState(() {});
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: _tabController.index == 1
                                ? const Color(0xFF7DBF6C) // Hijau jika aktif
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            "Masuk",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: _tabController.index == 1
                                  ? FontWeight.w900
                                  : FontWeight.w400,
                              color: _tabController.index == 1
                                  ? Colors.white
                                  : const Color(0xFF4A2619).withOpacity(0.6),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 40),

                // Container putih untuk form
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 24),
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF4A2619).withOpacity(0.1),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // Divider atas
                      const Divider(
                        thickness: 1.5,
                        color: Color(0xFF4A2619),
                      ),

                      const SizedBox(height: 32),

                      // Form sesuai tab aktif
                      SizedBox(
                        height: 500,
                        child: TabBarView(
                          controller: _tabController,
                          children: [
                            buildRegisterForm(),
                            buildLoginForm(),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  // ---------------- DAFTAR FORM ----------------
  Widget buildRegisterForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 10),
        
        // Judul Nama Pengguna
        const Text(
          "## Nama Pengguna",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: Color(0xFF4A2619),
            height: 2.0,
          ),
        ),
        
        // Field Nama Pengguna
        _buildTextFieldWithCheckbox(
          hint: "Ketik Nama Pengguna",
          icon: Icons.person_outline,
          hasCheckmark: false,
        ),

        const SizedBox(height: 24),

        // Email section
        const Text(
          "## Email",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: Color(0xFF4A2619),
            height: 2.0,
          ),
        ),
        
        // Row untuk checkbox dan field email
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 24,
              height: 24,
              margin: const EdgeInsets.only(top: 20, right: 12),
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFF7DBF6C), width: 2),
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Center(
                child: Icon(
                  Icons.check,
                  size: 16,
                  color: Color(0xFF7DBF6C),
                ),
              ),
            ),
            Expanded(
              child: _buildTextFieldWithCheckbox(
                hint: "Ketik Email",
                icon: Icons.email_outlined,
                hasCheckmark: true,
                isEmail: true,
              ),
            ),
          ],
        ),

        const SizedBox(height: 32),

        // Divider
        const Divider(
          thickness: 1.5,
          color: Color(0xFF4A2619),
        ),

        const SizedBox(height: 24),

        // Kata Sandi section
        const Text(
          "## Kata Sandi",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: Color(0xFF4A2619),
            height: 2.0,
          ),
        ),
        
        _buildTextFieldWithCheckbox(
          hint: "Ketik Kata Sandi",
          icon: Icons.lock_outline,
          isPassword: true,
          hasCheckmark: false,
        ),

        const SizedBox(height: 20),

        // Konfirmasi Kata Sandi
        const Text(
          "## Konfirmasi Kata Sandi",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: Color(0xFF4A2619),
            height: 2.0,
          ),
        ),
        
        _buildTextFieldWithCheckbox(
          hint: "Konfirmasi Kata Sandi",
          icon: Icons.lock_outline,
          isPassword: true,
          hasCheckmark: false,
          isConfirmPassword: true,
        ),

        const SizedBox(height: 32),

        // Tombol Daftar
        Center(
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF7DBF6C).withOpacity(0.4),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF7DBF6C),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 60,
                  vertical: 16,
                ),
                elevation: 0,
              ),
              child: const Text(
                "**Masuk**",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),

        const SizedBox(height: 24),

        // Tombol Google (TAMPILAN LAMA)
        Center(
          child: OutlinedButton(
            onPressed: () {},
            style: OutlinedButton.styleFrom(
              side: const BorderSide(
                color: Color(0xFF7DBF6C),
                width: 2,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: 32,
                vertical: 16,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: const Color(0xFF4A2619),
                      width: 2,
                    ),
                  ),
                  child: const Center(
                    child: Text(
                      'G',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF4A2619),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Masuk lewat Google',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF4A2619),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ---------------- MASUK FORM ----------------
  Widget buildLoginForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 10),
        
        // Email section
        const Text(
          "## Email",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: Color(0xFF4A2619),
            height: 2.0,
          ),
        ),
        
        // Row untuk checkbox dan field email
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 24,
              height: 24,
              margin: const EdgeInsets.only(top: 20, right: 12),
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFF7DBF6C), width: 2),
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Center(
                child: Icon(
                  Icons.check,
                  size: 16,
                  color: Color(0xFF7DBF6C),
                ),
              ),
            ),
            Expanded(
              child: _buildTextFieldWithCheckbox(
                hint: "Ketik Email",
                icon: Icons.email_outlined,
                hasCheckmark: true,
                isEmail: true,
              ),
            ),
          ],
        ),

        const SizedBox(height: 32),

        // Divider
        const Divider(
          thickness: 1.5,
          color: Color(0xFF4A2619),
        ),

        const SizedBox(height: 24),

        // Kata Sandi section
        const Text(
          "## Kata Sandi",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: Color(0xFF4A2619),
            height: 2.0,
          ),
        ),
        
        _buildTextFieldWithCheckbox(
          hint: "Ketik Kata Sandi",
          icon: Icons.lock_outline,
          isPassword: true,
          hasCheckmark: false,
        ),

        const SizedBox(height: 32),

        // Tombol Masuk
        Center(
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF7DBF6C).withOpacity(0.4),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF7DBF6C),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 60,
                  vertical: 16,
                ),
                elevation: 0,
              ),
              child: const Text(
                "**Masuk**",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),

        const SizedBox(height: 24),

        // Tombol Google (TAMPILAN LAMA)
        Center(
          child: OutlinedButton(
            onPressed: () {},
            style: OutlinedButton.styleFrom(
              side: const BorderSide(
                color: Color(0xFF7DBF6C),
                width: 2,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: 32,
                vertical: 16,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: const Color(0xFF4A2619),
                      width: 2,
                    ),
                  ),
                  child: const Center(
                    child: Text(
                      'G',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF4A2619),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Masuk lewat Google',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF4A2619),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // Helper untuk membuat textfield dengan format checkbox
  Widget _buildTextFieldWithCheckbox({
    required String hint,
    required IconData icon,
    bool isPassword = false,
    bool isEmail = false,
    bool hasCheckmark = false,
    bool isConfirmPassword = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      child: TextField(
        obscureText: isPassword && !(isConfirmPassword ? _showConfirmPassword : _showPassword),
        style: const TextStyle(
          fontSize: 16,
          color: Color(0xFF4A2619),
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          hintText: "- [ ] $hint",
          hintStyle: TextStyle(
            color: const Color(0xFF4A2619).withOpacity(0.7),
            fontSize: 16,
            fontWeight: FontWeight.w500,
            fontStyle: FontStyle.italic,
          ),
          prefixIcon: Icon(
            icon,
            color: const Color(0xFF7DBF6C),
          ),
          suffixIcon: isPassword
              ? IconButton(
                  icon: Icon(
                    (isConfirmPassword ? _showConfirmPassword : _showPassword)
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    color: const Color(0xFF4A2619).withOpacity(0.5),
                  ),
                  onPressed: () {
                    setState(() {
                      if (isConfirmPassword) {
                        _showConfirmPassword = !_showConfirmPassword;
                      } else {
                        _showPassword = !_showPassword;
                      }
                    });
                  },
                )
              : (hasCheckmark && isEmail)
                  ? const Icon(
                      Icons.check_circle,
                      color: Color(0xFF7DBF6C),
                    )
                  : null,
          filled: true,
          fillColor: const Color(0xFFFAF3E0).withOpacity(0.8),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 18,
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}