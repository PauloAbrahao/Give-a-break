class OverlayIconOption {
  final String name;
  final String icon;
  final String asset;

  const OverlayIconOption({
    required this.name,
    required this.icon,
    required this.asset,
  });

  static const List<OverlayIconOption> options = [
    OverlayIconOption(name: 'Clock', icon: 'clock', asset: 'assets/icons/clock.svg'),
    OverlayIconOption(name: 'Block', icon: 'block', asset: 'assets/icons/block.svg'),
    OverlayIconOption(name: 'Pause', icon: 'pause', asset: 'assets/icons/carbon_pause-outline.svg'),
    OverlayIconOption(name: 'Warning', icon: 'warning', asset: 'assets/icons/warning.svg'),
    OverlayIconOption(name: 'House', icon: 'house', asset: 'assets/icons/house.svg'),
    OverlayIconOption(name: 'Work', icon: 'work', asset: 'assets/icons/work.svg'),
    OverlayIconOption(name: 'Bedtime', icon: 'bedtime', asset: 'assets/icons/bedtime.svg'),
    OverlayIconOption(name: 'Sun', icon: 'sun', asset: 'assets/icons/sun.svg'),
    OverlayIconOption(name: 'Food', icon: 'food', asset: 'assets/icons/mdi_food.svg'),
    OverlayIconOption(name: 'Gym', icon: 'gym', asset: 'assets/icons/gym.svg'),
    OverlayIconOption(name: 'Movie', icon: 'movie', asset: 'assets/icons/movie.svg'),
    OverlayIconOption(name: 'Game', icon: 'game', asset: 'assets/icons/game.svg'),
    OverlayIconOption(name: 'Car', icon: 'car', asset: 'assets/icons/car.svg'),
    OverlayIconOption(name: 'Battery', icon: 'battery', asset: 'assets/icons/battery.svg'),
  ];

  static String get defaultIcon => options.first.icon;

  static String? getAssetForIcon(String? iconName) {
    if (iconName == null) return null;
    final option = options.where((o) => o.icon == iconName).firstOrNull;
    return option?.asset;
  }
}
