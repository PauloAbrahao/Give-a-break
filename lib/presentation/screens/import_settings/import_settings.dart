import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:give_a_break/core/constants/app_colors.dart';
import 'package:give_a_break/core/constants/app_strings.dart';
import 'package:give_a_break/presentation/providers/data_transfer_provider.dart';
import 'package:give_a_break/presentation/widgets/dialog.dart';

import 'widgets/action_card.dart';
import 'widgets/result_snackbar.dart';

class DataImportExportScreen extends ConsumerWidget {
  const DataImportExportScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dataTransferState = ref.watch(dataTransferProvider);
    final isLoading = dataTransferState is AsyncLoading;

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
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                ActionCard(
                  icon: Icons.upload_outlined,
                  title: AppStrings.exportTitle,
                  description: AppStrings.exportDescription,
                  buttonText: AppStrings.exportTitle,
                  isLoading: isLoading,
                  onPressed: () async {
                    final result = await ref
                        .read(dataTransferProvider.notifier)
                        .exportData();
                    if (context.mounted) {
                      showResultSnackBar(context, result);
                    }
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
                ActionCard(
                  icon: Icons.download_outlined,
                  title: AppStrings.importTitle,
                  description: AppStrings.importDescription,
                  buttonText: AppStrings.importTitle,
                  isLoading: isLoading,
                  onPressed: () {
                    _dialogConfirmation(context, ref);
                  },
                ),
              ],
            ),
          ),
          if (isLoading)
            Container(
              color: Colors.black.withOpacity(0.3),
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }
  
  void _dialogConfirmation(BuildContext context, WidgetRef ref) {
    AppDialog.show(
      context: context,
      title: 'Confirm Import',
      content:
          'Importing data may overwrite your current data. Are you sure you want to continue?',
      confirmText: 'Import',
      confirmButtonColor: AppColors.primary,
      onConfirm: () async {
        Navigator.pop(context);

        final result = await ref
            .read(dataTransferProvider.notifier)
            .importData();

        if (context.mounted) {
          showResultSnackBar(context, result);
        }
      },
    );
  }
}

