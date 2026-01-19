import 'package:flutter/material.dart';
import '../../../../core/constants/app_strings.dart';
import 'onboarding_page_indicator.dart';

class OnboardingBottomSection extends StatelessWidget {
  final int pageCount;
  final int currentPage;
  final bool isLastPage;
  final VoidCallback onNext;
  final VoidCallback onBack;

  const OnboardingBottomSection({
    super.key,
    required this.pageCount,
    required this.currentPage,
    required this.isLastPage,
    required this.onNext,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          OnboardingPageIndicator(
            pageCount: pageCount,
            currentPage: currentPage,
          ),
          const SizedBox(height: 32),
          Row(
            children: [
              if (currentPage > 0)
                TextButton(
                  onPressed: onBack,
                  child: const Text('Back'),
                ),
              const Spacer(),
              ElevatedButton(
                onPressed: onNext,
                child: Text(
                  isLastPage ? AppStrings.next : AppStrings.next,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
