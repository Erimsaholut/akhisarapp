import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'home.dart';


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
                    onPressed: () async {
                      final email = emailController.text.trim();
                      final password = passwordController.text.trim();
                      if (email.isEmpty || password.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Lütfen e-posta ve şifre girin')),
                        );
                        return;
                      }
                      try {
                        UserCredential cred;
                        try {
                          cred = await FirebaseAuth.instance.signInWithEmailAndPassword(
                            email: email,
                            password: password,
                          );
                        } on FirebaseAuthException catch (e) {
                          if (e.code == 'user-not-found') {
                            cred = await FirebaseAuth.instance.createUserWithEmailAndPassword(
                              email: email,
                              password: password,
                            );
                          } else {
                            rethrow;
                          }
                        }

                        final userRef = FirebaseFirestore.instance.collection('users').doc(cred.user!.uid);
                        final userDoc = await userRef.get();

                        if (!userDoc.exists) {
                          await userRef.set({
                            'email': cred.user!.email,
                            'username': '',
                            'role': 'user',
                            'createdAt': FieldValue.serverTimestamp(),
                          });
                        }

                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => const HomeScreen()),
                        );
                      } on FirebaseAuthException catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(e.message ?? 'Bir hata oluştu')),
                        );
                      }
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