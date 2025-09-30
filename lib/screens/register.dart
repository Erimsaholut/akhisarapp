import 'package:flutter/material.dart';

class AuthOptionsScreen extends StatelessWidget {
  const AuthOptionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final TextEditingController emailController = TextEditingController();
    final TextEditingController passwordController = TextEditingController();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Giriş / Üye Ol'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/background.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'AkhisApp',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 30),

                // 📧 Email & Password
                TextField(
                  controller: emailController,
                  decoration: const InputDecoration(
                    labelText: 'E-posta',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 15),
                TextField(
                  controller: passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Şifre',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF666666),
                    ),
                    onPressed: () {
                      debugPrint('Email & Şifre Girişi');
                    },
                    child: const Text(
                      'Giriş Yap / Üye Ol',
                      style: TextStyle(fontSize: 18, color: Colors.white),
                    ),
                  ),
                ),

                const SizedBox(height: 30),
                const Divider(thickness: 1),
                const SizedBox(height: 10),
                const Text(
                  'VEYA',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 10),

                // 🔵 Google
                SizedBox(
                  height: 50,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                    ),
                    onPressed: () {
                      debugPrint('Google Girişi');
                    },
                    icon: Image.asset(
                      'assets/google.png',
                      height: 24,
                    ),
                    label: const Text('Google ile Giriş Yap'),
                  ),
                ),
                const SizedBox(height: 15),

                // 🟠 Telefon
                SizedBox(
                  height: 50,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange.shade600,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: () {
                      debugPrint('Telefon ile Giriş');
                    },
                    icon: const Icon(Icons.phone),
                    label: const Text('Telefon Numarası ile Giriş'),
                  ),
                ),
                const SizedBox(height: 15),

                // ⚪ Apple (iOS için)
                SizedBox(
                  height: 50,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: () {
                      debugPrint('Apple ile Giriş');
                    },
                    icon: const Icon(Icons.apple),
                    label: const Text('Apple ile Giriş'),
                  ),
                ),
                const SizedBox(height: 15),

                // 🟣 Misafir Girişi
                TextButton(
                  onPressed: () {
                    debugPrint('Misafir Girişi');
                  },
                  child: const Text(
                    'Misafir olarak devam et',
                    style: TextStyle(decoration: TextDecoration.underline),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}