import 'package:flutter/material.dart';
import 'package:give_a_break/core/constants/app_colors.dart';
import 'package:give_a_break/presentation/providers/data_transfer_provider.dart';

void showResultSnackBar(BuildContext context, DataTransferResult result) {
  ScaffoldMessenger.of(context).clearSnackBars();
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Center(
        heightFactor: 1,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          decoration: BoxDecoration(
            color: result.success ? AppColors.success : AppColors.error,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            result.message,
            style: const TextStyle(color: Colors.white),
          ),
        ),
      ),
      backgroundColor: Colors.transparent,
      elevation: 0,
      behavior: SnackBarBehavior.floating,
      margin: const EdgeInsets.only(bottom: 16),
    ),
  );
}
