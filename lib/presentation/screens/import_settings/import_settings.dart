import 'package:flutter/material.dart';
import 'package:give_a_break/core/constants/app_colors.dart';
import 'package:give_a_break/core/constants/app_strings.dart';

class DataImportExportScreen extends StatelessWidget {
  const DataImportExportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.getBackground(context),
      appBar: AppBar(
        backgroundColor: AppColors.getBackground(context),
        elevation: 0,
        leading: const BackButton(),
        title: const Text(
          AppStrings.import,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _ActionCard(
              icon: Icons.upload_file_outlined,
              title: 'Export',
              description:
                  'Back up your limits and routines and restore them at a later point',
              buttonText: 'Export',
              onPressed: () {
                // TODO: Export logic
              },
            ),
            const SizedBox(height: 24),
            Padding(    
              padding: const EdgeInsets.symmetric(horizontal: 50),
              child: Divider(
                color: AppColors.getDivider(context),
                thickness: 1,
              ),
            ),
            const SizedBox(height: 24),
            _ActionCard(
              icon: Icons.download_outlined,
              title: 'Import',
              description:
                  'Restore previously exported data to get your limits and routines back',
              buttonText: 'Import',
              onPressed: () {
                // TODO: Import logic
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final String buttonText;
  final VoidCallback onPressed;

  const _ActionCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.buttonText,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      decoration: BoxDecoration(
        color: AppColors.getSurface(context),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.getTextPrimary(context).withOpacity(0.05),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 40,
            color: AppColors.getTextPrimary(context).withOpacity(0.9),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w500,
              color: AppColors.getTextPrimary(context),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            description,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: AppColors.getTextPrimary(context).withOpacity(0.7),
              height: 1.4,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: onPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.getTextPrimary(context),
              padding: const EdgeInsets.symmetric(
                horizontal: 32,
                vertical: 14,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            child: Text(
              buttonText,
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
