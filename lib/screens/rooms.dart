import 'package:flutter/material.dart';

class RoomsScreen extends StatelessWidget {
  const RoomsScreen({super.key});

  final List<String> _rooms = const [
    'Oda 1',
    'Oda 2',
    'Oda 3',
    'Oda 4',
    'Oda 5',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Odalar'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 20),
        itemCount: _rooms.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 10),
            child: SizedBox(
              width: 250,
              height: 60,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF666666),
                ),
                onPressed: () {
                  debugPrint('${_rooms[index]} butonuna basıldı');
                },
                child: Text(
                  _rooms[index],
                  style: const TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}