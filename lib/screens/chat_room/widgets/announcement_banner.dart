import '../../../theme/app_colors.dart';
import 'package:flutter/material.dart';

class AnnouncementBanner extends StatelessWidget {
  const AnnouncementBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(12),
      child: Text(
        'Sadece yöneticiler bu odaya mesaj yazabilir.',
        style: TextStyle(color: kSageGreenSecondary),
      ),
    );
  }
}
