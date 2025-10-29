import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'home.dart';
import '../theme/app_colors.dart'; // tema renkleri

class UsernameSetupScreen extends StatefulWidget {
  const UsernameSetupScreen({super.key});

  @override
  State<UsernameSetupScreen> createState() => _UsernameSetupScreenState();
}

class _UsernameSetupScreenState extends State<UsernameSetupScreen> {
  final TextEditingController _usernameController = TextEditingController();
  bool _loading = false;

  Future<void> _saveUsername() async {
    final username = _usernameController.text.trim();
    if (username.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Lütfen bir kullanıcı adı girin'),
          backgroundColor: kTerracottaAccent,
        ),
      );
      return;
    }

    setState(() => _loading = true);
    final usersRef = FirebaseFirestore.instance.collection('users');

    final existing =
    await usersRef.where('username', isEqualTo: username).get();
    if (existing.docs.isNotEmpty) {
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Bu kullanıcı adı zaten kullanılıyor'),
          backgroundColor: kTerracottaAccent,
        ),
      );
      return;
    }

    final uid = FirebaseAuth.instance.currentUser!.uid;
    await usersRef.doc(uid).update({'username': username});

    setState(() => _loading = false);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Kullanıcı adı kaydedildi'),
          backgroundColor: kOliveGreenPrimary,
        ),
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBeigeBackground,
      appBar: AppBar(
        backgroundColor: kOliveGreenPrimary,
        title: const Text('Kullanıcı Adı Belirle'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Kullanıcı adınızı belirleyin:',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: kDarkText,
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _usernameController,
              cursorColor: kOliveGreenPrimary,
              decoration: InputDecoration(
                labelText: 'Kullanıcı Adı',
                labelStyle: const TextStyle(color: kDarkText),
                filled: true,
                fillColor: kCardSurface,
                enabledBorder: OutlineInputBorder(
                  borderSide:
                  BorderSide(color: kSageGreenSecondary.withOpacity(0.5)),
                ),
                focusedBorder: const OutlineInputBorder(
                  borderSide:
                  BorderSide(color: kOliveGreenPrimary, width: 2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            _loading
                ? const CircularProgressIndicator(color: kOliveGreenPrimary)
                : ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: kOliveGreenPrimary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                    vertical: 14, horizontal: 28),
                textStyle: const TextStyle(
                    fontSize: 16, fontWeight: FontWeight.w600),
              ),
              onPressed: _saveUsername,
              child: const Text('Kaydet'),
            ),
          ],
        ),
      ),
    );
  }
}