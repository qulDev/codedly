import 'package:codedly/core/navigation/routes.dart';
import 'package:codedly/core/theme/colors.dart';
import 'package:flutter/material.dart';

class CustomBottomNavBar extends StatelessWidget {
  final int currentIndex;
  
  const CustomBottomNavBar({
    super.key,
    required this.currentIndex,
  });

  static const _routes = {
    0: AppRoutes.home,
    2: AppRoutes.leaderboard,
    // ...
    3: AppRoutes.profile,
  };

  void _onItemTapped(BuildContext context, int index) {
    if (index == currentIndex) return;
    
    final route = _routes[index];
    
    if (route != null) {
      Navigator.pushNamedAndRemoveUntil(
        context,
        route,
        (route) => false,
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Tab ${index + 1} coming soon! 🚀')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      backgroundColor: AppColors.surface,
      selectedItemColor: AppColors.primary,
      unselectedItemColor: AppColors.textSecondary,
      type: BottomNavigationBarType.fixed,
      currentIndex: currentIndex,
      onTap: (index) => _onItemTapped(context, index),
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
        BottomNavigationBarItem(icon: Icon(Icons.quiz), label: 'Practice'),
        BottomNavigationBarItem(icon: Icon(Icons.leaderboard), label: 'Leaderboard'),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
      ],
    );
  }
}
