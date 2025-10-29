import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../screens/friends/friends_screen.dart';
import 'settings.dart';
import 'rooms.dart';
import 'login.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBeigeBackground,
      appBar: AppBar(
        backgroundColor: kOliveGreenPrimary,
        title: const Text('AkhisApp'),
        // Artık 'backgroundColor' burada değil, app_theme.dart dosyasından geliyor.
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Çıkış Yap',
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    // Dialog stilleri de temadan etkilenecek (örn: shape, titleTextStyle)
                    title: const Text('Çıkış Yap'),
                    content:
                    const Text('Oturumu kapatmak istediğine emin misin?'),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        // TextButton rengini otomatik olarak temadan (primaryColor) alacak
                        child: const Text('İptal'),
                      ),
                      TextButton(
                        onPressed: () async {
                          await FirebaseAuth.instance.signOut();
                          Navigator.of(context).pushAndRemoveUntil(
                            MaterialPageRoute(
                                builder: (context) => const LoginScreen()),
                                (route) => false,
                          );
                        },
                        child: const Text('Evet'),
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ],
        // backgroundColor: Theme.of(context).colorScheme.inversePrimary, // <-- BU SATIRI KALDIRDIK
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 250,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  // backgroundColor: const Color(0xFF666666), // <-- TEMADAN ALINACAK
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  textStyle: const TextStyle(fontSize: 16),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const RoomsScreen()),
                  );
                },
                // Yazı rengi (foregroundColor) artık 'elevatedButtonTheme'den geliyor
                child: const Text('Odalar'),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: 250,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  // backgroundColor: const Color(0xFF666666), // <-- TEMADAN ALINACAK
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  textStyle: const TextStyle(fontSize: 16),
                ),
                onPressed: () {
                  debugPrint('Direkt Mesaj pressed');
                },
                child:
                const Text('Direkt Mesaj'), // <-- 'style' kaldırıldı
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: 250,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  // backgroundColor: const Color(0xFF666666), // <-- TEMADAN ALINACAK
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  textStyle: const TextStyle(fontSize: 16),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const FriendsScreen()),
                  );
                },
                child: const Text('Arkadaşlar'), // <-- 'style' kaldırıldı
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: 250,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  // backgroundColor: const Color(0xFF666666), // <-- TEMADAN ALINACAK
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  textStyle: const TextStyle(fontSize: 16),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const SettingsScreen()),
                  );
                },
                child: const Text('Ayarlar'), // <-- 'style' kaldırıldı
              ),
            ),
          ],
        ),
      ),
    );
  }
}

