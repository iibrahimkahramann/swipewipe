import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:swipewipe/config/theme/custom_theme.dart';
import 'package:flutter_snake_navigationbar/flutter_snake_navigationbar.dart';

class CustomNavBar extends StatelessWidget {
  const CustomNavBar({
    super.key,
    required this.currentLocation,
  });

  final String currentLocation;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return SnakeNavigationBar.color(
      behaviour: SnakeBarBehaviour.floating,
      snakeShape: SnakeShape.circle,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(30),
      ),
      padding: EdgeInsets.symmetric(
        horizontal: width * 0.1,
      ),
      snakeViewColor: CustomTheme.boldColor,
      selectedItemColor: SnakeShape.circle == SnakeShape.indicator
          ? CustomTheme.backgroundColor
          : null,
      unselectedItemColor: CustomTheme.accentColor,
      showUnselectedLabels: false,
      showSelectedLabels: false,
      backgroundColor: CustomTheme.backgroundColor,
      currentIndex: _calculateSelectedIndex(currentLocation),
      onTap: (index) => _onItemTapped(index, context),
      items: [
        BottomNavigationBarItem(
          icon: Image.asset(
            'assets/icons/organize.png',
            color: _calculateSelectedIndex(currentLocation) == 0
                ? CustomTheme.backgroundColor
                : Colors.white,
            width: width * 0.07,
          ),
        ),
        BottomNavigationBarItem(
          icon: Image.asset(
            'assets/icons/albums.png',
            color: _calculateSelectedIndex(currentLocation) == 1
                ? CustomTheme.backgroundColor
                : Colors.white,
            width: width * 0.07,
          ),
        ),
        BottomNavigationBarItem(
          icon: Image.asset(
            'assets/icons/settings.png',
            color: _calculateSelectedIndex(currentLocation) == 2
                ? CustomTheme.backgroundColor
                : Colors.white,
            width: width * 0.07,
          ),
        ),
      ],
    );
  }

  int _calculateSelectedIndex(String location) {
    if (location.startsWith('/organize')) return 0;
    if (location.startsWith('/albums')) return 1;
    if (location.startsWith('/settings')) return 2;

    return 0;
  }

  void _onItemTapped(int index, BuildContext context) {
    switch (index) {
      case 0:
        context.go('/organize');
        break;
    }
    switch (index) {
      case 1:
        context.go('/albums');
        break;
    }
    switch (index) {
      case 2:
        context.go('/settings');
        break;
    }
  }
}
