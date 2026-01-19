import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../data/models/onboarding_page_model.dart';
import 'widgets/widgets.dart';
import 'permission_setup_screen.dart';

class OnboardingScreen extends StatefulWidget {
  final bool fromSettings;

  const OnboardingScreen({
    super.key,
    this.fromSettings = false,
  });

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingPageModel> _pages = [
    OnboardingPageModel(
      icon: Icons.waving_hand,
      title: AppStrings.onboardingWelcomeTitle,
      subtitle: AppStrings.onboardingWelcomeSubtitle,
      color: AppColors.primary,
    ),
    OnboardingPageModel(
      icon: Icons.bar_chart_rounded,
      title: AppStrings.onboardingUsageTitle,
      subtitle: AppStrings.onboardingUsageSubtitle,
      color: AppColors.info,
    ),
    OnboardingPageModel(
      icon: Icons.timer_rounded,
      title: AppStrings.onboardingLimitsTitle,
      subtitle: AppStrings.onboardingLimitsSubtitle,
      color: AppColors.success,
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _goToPermissions();
    }
  }

  void _previousPage() {
    _pageController.previousPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _goToPermissions() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => PermissionSetupScreen(fromSettings: widget.fromSettings),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _pages.length,
                onPageChanged: (index) {
                  setState(() => _currentPage = index);
                },
                itemBuilder: (context, index) {
                  return OnboardingPageContent(page: _pages[index]);
                },
              ),
            ),
            OnboardingBottomSection(
              pageCount: _pages.length,
              currentPage: _currentPage,
              isLastPage: _currentPage == _pages.length - 1,
              onNext: _nextPage,
              onBack: _previousPage,
            ),
          ],
        ),
      ),
    );
  }
}
