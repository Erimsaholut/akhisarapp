import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../theme/app_colors.dart';

class UserProfileScreen extends StatelessWidget {
  final String userId;

  const UserProfileScreen({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBeigeBackground,
      appBar: AppBar(
        backgroundColor: kOliveGreenPrimary,
        title: const Text(
          'Kullanıcı Profili',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance.collection('users').doc(userId).get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: kOliveGreenPrimary),
            );
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(
              child: Text(
                'Kullanıcı bulunamadı',
                style: TextStyle(fontSize: 18, color: kSageGreenSecondary),
              ),
            );
          }

          final data = snapshot.data!.data() as Map<String, dynamic>;
          final username = data['username'] ?? 'Bilinmeyen';
          final bioText = data['bioText'] ?? '';

          return LayoutBuilder(
            builder: (context, constraints) {
              final isTablet = constraints.maxWidth > 600;
              final iconSize = isTablet ? 200.0 : 180.0;
              final usernameFont = isTablet ? 32.0 : 32.0;
              final bioFont = isTablet ? 20.0 : 20.0;
              final horizontalPadding = isTablet ? 48.0 : 32.0;
              final topPadding = isTablet ? 60.0 : 36.0;
              final sidePadding = isTablet ? 48.0 : 24.0;
              return Center(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(sidePadding, topPadding, sidePadding, 16),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.account_circle,
                          size: iconSize, color: kSageGreenSecondary),
                      const SizedBox(height: 30),
                      Text(
                        username,
                        style: TextStyle(
                          fontSize: usernameFont,
                          fontWeight: FontWeight.bold,
                          color: kDarkText,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        bioText.isNotEmpty
                            ? bioText
                            : 'Bu kullanıcı henüz bir biyografi eklememiş.',
                        style: TextStyle(
                          fontSize: bioFont,
                          color: kSageGreenSecondary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
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