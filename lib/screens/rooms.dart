import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../theme/app_colors.dart'; // temadaki renkleri almak için eklendi
import 'chat_room.dart';

class RoomsScreen extends StatelessWidget {
  const RoomsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBeigeBackground, // temadaki arka plan rengi
      appBar: AppBar(
        backgroundColor: kOliveGreenPrimary, // temadaki AppBar rengi
        title: const Text('Odalar'),
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('rooms').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                'Hiç oda yok',
                style: TextStyle(color: kDarkText), // temadaki metin rengi
              ),
            );
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
                    // Stil tanımlamaya gerek yok, her şey temadan gelecek.
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
                      style: const TextStyle(fontSize: 18), // yalnızca boyut, renk temadan
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