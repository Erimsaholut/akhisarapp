import 'package:flutter/material.dart';

// Tema dosyanızın yolu projenizin yapısına göre değişebilir
// Muhtemelen bu yoldur:
import '../../../theme/app_colors.dart';

class AnnouncementBanner extends StatelessWidget {
  // 'const' constructor, 'Not a constant expression' hatasını çözer
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