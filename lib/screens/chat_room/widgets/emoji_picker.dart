import 'package:flutter/material.dart';

class EmojiPicker extends StatelessWidget {

  // 1. Haritayı buraya 'static const' olarak taşıdık
  static const Map<String, String> oldschoolEmojis = {
    ':)': 'assets/emojis/smile.png',
    ':(': 'assets/emojis/sad.png',
    ':P': 'assets/emojis/tongue.png',
    ';)': 'assets/emojis/wink.png',
    ':D': 'assets/emojis/laugh.png',
    ':-O': 'assets/emojis/surprised.png',
    '8-)': 'assets/emojis/cool.png',
    '<3': 'assets/emojis/heart.png',
    '</3': 'assets/emojis/brokenheart.png',
    ':-*': 'assets/emojis/kiss.png',
    ':-x': 'assets/emojis/secret.png',
    '(*)': 'assets/emojis/star.png',
    '(K)': 'assets/emojis/kissmark.png',
    ':@': 'assets/emojis/angry.png',
    ':[': 'assets/emojis/devil.png',
    ':-[': 'assets/emojis/vampire.png',
    ':p': 'assets/emojis/sick.png',
    '(roll)': 'assets/emojis/roll.png',
    '<:o)': 'assets/emojis/party.png',
    '^o)': 'assets/emojis/sarcastic.png',
    ':\'(': 'assets/emojis/cry.png',
  };

  final void Function(String) onEmojiSelected;

  const EmojiPicker({
    super.key,
    required this.onEmojiSelected,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 6,
      // 3. Doğrudan 'oldschoolEmojis' sabitini kullanın
      children: oldschoolEmojis.entries.map((entry) {
        return IconButton(
          icon: Image.asset(entry.value),
          onPressed: () => onEmojiSelected(entry.key),
        );
      }).toList(),
    );
  }
}