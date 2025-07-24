import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../utils/app_colors.dart';

class OnboardingTutorialScreen extends ConsumerStatefulWidget {
  const OnboardingTutorialScreen({super.key});

  @override
  ConsumerState<OnboardingTutorialScreen> createState() => _OnboardingTutorialScreenState();
}

class _OnboardingTutorialScreenState extends ConsumerState<OnboardingTutorialScreen> {
  int _currentPage = 0;

  // Tutorial 이미지 리스트 (Tutorial 1.png ~ Tutorial 6.png)
  final List<String> _tutorialImages = [
    'assets/images/Tutorial 1.png',
    'assets/images/Tutorial 2.png',
    'assets/images/Tutorial 3.png',
    'assets/images/Tutorial 4.png',
    'assets/images/Tutorial 5.png',
    'assets/images/Tutorial 6.png',
  ];

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // 고정된 배경으로 현재 페이지 이미지만 표시
          _buildTutorialImage(_tutorialImages[_currentPage]),
          // 페이지 인디케이터만 표시
          Positioned(
            bottom: MediaQuery.of(context).padding.bottom + 32,
            left: 20,
            right: 20,
            child: _buildPageIndicators(),
          ),
        ],
      ),
    );
  }

  Widget _buildTutorialImage(String imagePath) {
    return GestureDetector(
      onTap: _nextPage,
      child: Image.asset(
        imagePath,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
      ),
    );
  }

  Widget _buildPageIndicators() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        _tutorialImages.length,
        (index) => _buildPageIndicator(index),
      ),
    );
  }

  Widget _buildPageIndicator(int index) {
    final isActive = index == _currentPage;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      width: isActive ? 24 : 8,
      height: 8,
      decoration: BoxDecoration(
        color: isActive 
            ? AppColors.textWhite 
            : AppColors.textWhite.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }

  void _nextPage() {
    if (_currentPage < _tutorialImages.length - 1) {
      setState(() {
        _currentPage++;
      });
    } else {
      _completeTutorial();
    }
  }

  void _completeTutorial() {
    // GoRouter 사용 시
    context.go('/profile-setup');
  }
}