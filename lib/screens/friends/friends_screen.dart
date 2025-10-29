import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import 'tabs/friends_list_tab.dart';
import 'tabs/friend_requests_tab.dart';
import 'add_friend.dart';

class FriendsScreen extends StatelessWidget {
  const FriendsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: kBeigeBackground,
        appBar: AppBar(
          backgroundColor: kOliveGreenPrimary,
          title: const Text('Arkadaşlar'),
          centerTitle: true,
          bottom: const TabBar(
            indicatorColor: Colors.white,
            labelColor: Colors.white,
            unselectedLabelColor: kCardSurface,
            tabs: [
              Tab(text: 'Arkadaşlar'),
              Tab(text: 'İstekler'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            // Temiz bir şekilde sekme widget'larını çağırıyoruz
            FriendsListTab(),
            FriendRequestsTab(),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => AddFriendScreen()),
            );
          },
          icon: const Icon(Icons.person_add),
          label: const Text('Yeni Ekle'),
          backgroundColor: kOliveGreenPrimary,
          foregroundColor: Colors.white,
        ),
      ),
    );
  }
}
