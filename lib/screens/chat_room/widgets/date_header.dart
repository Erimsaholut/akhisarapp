import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../theme/app_colors.dart'; // Tema import yolunu güncelleyin

class DateHeader extends StatelessWidget {
  final String date; // 'yyyy-MM-dd' formatında
  const DateHeader({super.key, required this.date});

  @override
  Widget build(BuildContext context) {
    final dateTime = DateTime.parse(date);
    final formattedDate =
    DateFormat('MMMM d, yyyy', 'en_US').format(dateTime);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Center(
        child: Text(
          formattedDate,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: kSageGreenSecondary,
          ),
        ),
      ),
    );
  }
}