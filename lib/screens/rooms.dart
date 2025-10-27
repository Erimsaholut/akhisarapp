import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'chat_room.dart';

class RoomsScreen extends StatelessWidget {
  const RoomsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Bu sayfanın arka planı temadaki 'scaffoldBackgroundColor' (kBeigeBackground) olacak.
      appBar: AppBar(
        title: const Text('Odalar'),
        // backgroundColor: Theme.of(context).colorScheme.inversePrimary, // <-- BU SATIRI KALDIRDIK
        // Renk ve stil artık app_theme.dart dosyasından otomatik olarak geliyor.
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('rooms').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // CircularProgressIndicator da temadaki ana rengi (kOliveGreenPrimary) alacak.
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            // Metin rengi temadaki 'onBackground' (kDarkText) rengini alacak.
            return const Center(child: Text('Hiç oda yok'));
          }

          final rooms = snapshot.data!.docs;
          rooms.sort((a, b) {
            if ((a.data() as Map<String, dynamic>)['name'] == 'Duyuru Odası') return -1;
            if ((b.data() as Map<String, dynamic>)['name'] == 'Duyuru Odası') return 1;
            return 0;
          });

          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 20),
            itemCount: rooms.length,
            itemBuilder: (context, index) {
              final room = rooms[index];
              final roomName = room['name'] ?? 'Adsız Oda';
              final roomId = room.id;

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 10),
                child: SizedBox(
                  width: 250,
                  height: 60,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      // backgroundColor: const Color(0xFF666666), // <-- BU SATIRI KALDIRDIK
                      // Renk ve yazı rengi artık 'elevatedButtonTheme'den geliyor.
                      // Şekil (shape) de temadan alınacak.
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ChatRoomScreen(
                            roomId: roomId,
                            roomName: roomName,
                          ),
                        ),
                      );
                    },
                    child: Text(
                      roomName,
                      // Sadece yazı boyutunu burada belirttik, renk temadan geliyor.
                      style: const TextStyle(fontSize: 18),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
