import 'dart:typed_data';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:installed_apps/installed_apps.dart';
import '../../domain/entities/app_info.dart';

final installedAppsProvider = FutureProvider<List<AppInfo>>((ref) async {
  // Parameters: (excludeSystemApps, withIcon)
  final apps = await InstalledApps.getInstalledApps(true, true);

  final appInfoList = <AppInfo>[];
  for (final app in apps) {
    Uint8List? iconBytes;
    try {
      iconBytes = app.icon;
    } catch (_) {
      iconBytes = null;
    }

    appInfoList.add(AppInfo(
      packageName: app.packageName,
      appName: app.name,
      icon: iconBytes,
      isSystemApp: false,
    ));
  }

  // Sort alphabetically
  appInfoList.sort((a, b) => a.appName.compareTo(b.appName));

  return appInfoList;
});

final appInfoProvider =
    FutureProvider.family<AppInfo?, String>((ref, packageName) async {
  final apps = await ref.watch(installedAppsProvider.future);
  return apps.where((app) => app.packageName == packageName).firstOrNull;
});
