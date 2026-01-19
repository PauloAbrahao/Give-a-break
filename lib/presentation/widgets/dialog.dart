import 'package:flutter/material.dart';
import 'package:give_a_break/core/constants/app_strings.dart';
import '../../../../core/constants/app_colors.dart';

class AppDialog { 
  static Future<void> show({  
      required BuildContext context,
      required VoidCallback onConfirm,
      required String title,
      required String content,
      required String confirmText,
      required Color confirmButtonColor,
    }) {
    return showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.8),
      builder: (context) => AlertDialog(
        title: Text(title),
        backgroundColor: AppColors.getDialogColor(context),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              AppStrings.cancel,
              style: TextStyle(color: AppColors.getTextPrimary(context)),
            ),
          ),
          ElevatedButton(
            onPressed: onConfirm,
            style: ElevatedButton.styleFrom(
              backgroundColor: confirmButtonColor,
            ),
            child: Text(confirmText),
          ),
        ],
      ),
    );
  }
}