import 'package:flutter/material.dart';
import 'package:give_a_break/core/constants/app_colors.dart';
import 'package:give_a_break/presentation/providers/data_transfer_provider.dart';

void showResultSnackBar(BuildContext context, DataTransferResult result) {
  final overlay = Overlay.of(context);
  late OverlayEntry entry;

  final animationController = AnimationController(
    vsync: Navigator.of(context),
    duration: const Duration(milliseconds: 300),
  );

  final animation = Tween<Offset>(
    begin: const Offset(0, 0),
    end: const Offset(0, 1), 
  ).animate(CurvedAnimation(
    parent: animationController,
    curve: Curves.easeIn,
  ));

  void dismiss() async {
    await animationController.forward();
    entry.remove();
    animationController.dispose();
  }

  entry = OverlayEntry(
    builder: (context) => Positioned(
      bottom: 16,
      left: 16,
      right: 16,
      child: SlideTransition(
        position: animation,
        child: GestureDetector(
          onTap: dismiss, 
          child: Material(
            color: Colors.transparent,
            child: Center(
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                decoration: BoxDecoration(
                  color: result.success
                      ? AppColors.success
                      : AppColors.error,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  result.message,
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ),
          ),
        ),
      ),
    ),
  );

  overlay.insert(entry);

  Future.delayed(const Duration(seconds: 3), dismiss);
}
