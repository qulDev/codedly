
import 'package:codedly/core/navigation/routes.dart';
import 'package:codedly/core/theme/colors.dart';
import 'package:flutter/material.dart';

class CustomBottomNavBar extends StatelessWidget {
  final int currentIndex;
  
  const CustomBottomNavBar({
    super.key,
    required this.currentIndex,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      backgroundColor: AppColors.surface,
      selectedItemColor: AppColors.primary,
      unselectedItemColor: AppColors.textSecondary,
      type: BottomNavigationBarType.fixed,
      currentIndex: currentIndex,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
        BottomNavigationBarItem(icon: Icon(Icons.quiz), label: 'Practice'),
        BottomNavigationBarItem(icon: Icon(Icons.leaderboard), label: 'Leaderboard'),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
      ],
      onTap: (index) {
        if (index == currentIndex) return;
        
        switch (index) {
          case 0:
            Navigator.pushNamedAndRemoveUntil(
              context,
              AppRoutes.home,
              (route) => false,
            );
            break;
          case 1:
            // ...
            break;
          case 2:
            Navigator.pushNamedAndRemoveUntil(
              context,
              AppRoutes.leaderboard,
              (route) => false,
            );
            break;
          case 3:
            Navigator.pushNamedAndRemoveUntil(
              context,
              AppRoutes.profile,
              (route) => false,
            );
            break;
          default:
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Tab ${index + 1} coming soon! 🚀')),
          );
          break;
        }
      },
    );
  }
}