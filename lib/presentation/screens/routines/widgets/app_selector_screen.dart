import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../domain/entities/app_info.dart';
import '../../../providers/installed_apps_provider.dart';

class AppSelectorScreen extends ConsumerStatefulWidget {
  final Set<String> initialSelectedPackages;

  const AppSelectorScreen({
    super.key,
    required this.initialSelectedPackages,
  });

  @override
  ConsumerState<AppSelectorScreen> createState() => _AppSelectorScreenState();
}

class _AppSelectorScreenState extends ConsumerState<AppSelectorScreen> {
  late Set<String> _selectedPackages;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _selectedPackages = Set.from(widget.initialSelectedPackages);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final installedApps = ref.watch(installedAppsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Select Apps',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, _selectedPackages),
            child: Text(
              'Done (${_selectedPackages.length})',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSearchBar(context),
          Expanded(
            child: installedApps.when(
              data: (apps) => _buildAppsList(context, apps),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (_, __) => Center(
                child: Text(
                  'Error loading apps',
                  style: TextStyle(color: AppColors.getTextSecondary(context)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: TextField(
        controller: _searchController,
        onChanged: (value) => setState(() => _searchQuery = value),
        decoration: InputDecoration(
          hintText: 'Search apps',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () {
                    _searchController.clear();
                    setState(() => _searchQuery = '');
                  },
                )
              : null,
          filled: true,
          fillColor: AppColors.getSurfaceVariant(context),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
        ),
      ),
    );
  }

  Widget _buildAppsList(BuildContext context, List<AppInfo> apps) {
    final filteredApps = apps.where((app) {
      if (_searchQuery.isEmpty) return true;
      return app.appName.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();

    if (filteredApps.isEmpty) {
      return Center(
        child: Text(
          'No apps found',
          style: TextStyle(color: AppColors.getTextSecondary(context)),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: filteredApps.length,
      itemBuilder: (context, index) {
        final app = filteredApps[index];
        final isSelected = _selectedPackages.contains(app.packageName);

        return _AppListItem(
          app: app,
          isSelected: isSelected,
          onToggle: () {
            setState(() {
              if (isSelected) {
                _selectedPackages.remove(app.packageName);
              } else {
                _selectedPackages.add(app.packageName);
              }
            });
          },
        );
      },
    );
  }
}

class _AppListItem extends StatelessWidget {
  final AppInfo app;
  final bool isSelected;
  final VoidCallback onToggle;

  const _AppListItem({
    required this.app,
    required this.isSelected,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onToggle,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            _buildIcon(context),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                app.appName,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.getTextPrimary(context),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 12),
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : Colors.transparent,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: isSelected
                      ? AppColors.primary
                      : AppColors.getTextSecondary(context),
                  width: 2,
                ),
              ),
              child: isSelected
                  ? const Icon(
                      Icons.check,
                      size: 16,
                      color: Colors.white,
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIcon(BuildContext context) {
    if (app.icon != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Image.memory(
          app.icon!,
          width: 44,
          height: 44,
          fit: BoxFit.cover,
        ),
      );
    }

    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: const Icon(
        Icons.android,
        color: AppColors.primary,
        size: 24,
      ),
    );
  }
}
