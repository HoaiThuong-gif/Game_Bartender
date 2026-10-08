import 'package:flutter/material.dart';

import '../../games/gacha/screens/gacha_screen.dart';
import 'lobby_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedTab = 0;
  bool _gachaOpened = false;

  void _selectTab(int index) {
    if (index == _selectedTab) return;
    setState(() {
      _selectedTab = index;
      if (index == 1) _gachaOpened = true;
    });
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: IndexedStack(
      index: _selectedTab,
      children: [
        TickerMode(enabled: _selectedTab == 0, child: const LobbyScreen()),
        TickerMode(
          enabled: _selectedTab == 1,
          // Create Gacha on its first visit, then retain ticket and scroll state.
          child: _gachaOpened
              ? GachaScreen(isActive: _selectedTab == 1)
              : const SizedBox.shrink(),
        ),
      ],
    ),
    bottomNavigationBar: BottomNavigationBar(
      currentIndex: _selectedTab,
      onTap: _selectTab,
      backgroundColor: const Color(0xFFF3E9D5),
      selectedItemColor: const Color(0xFF974B37),
      unselectedItemColor: const Color(0xFF503A28),
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.storefront_outlined),
          label: 'Lobby',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.confirmation_number_outlined),
          label: 'Gacha',
        ),
      ],
    ),
  );
}
