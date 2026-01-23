class OverlayColorOption {
  final String name;
  final String color;

  const OverlayColorOption({required this.name, required this.color});

  static const List<OverlayColorOption> options = [
    OverlayColorOption(name: 'Default', color: '#6366F1'),
    OverlayColorOption(name: 'Purple', color: '#A855F7'),
    OverlayColorOption(name: 'Red', color: '#EF4444'),
    OverlayColorOption(name: 'Orange', color: '#F97316'),
    OverlayColorOption(name: 'Yellow', color: '#EAB308'),
    OverlayColorOption(name: 'Green', color: '#22C55E'),
    OverlayColorOption(name: 'StrongGreen', color: '#70e000'),
    OverlayColorOption(name: 'Blue', color: '#3B82F6'),
  ];

  static String get defaultColor => options.first.color;
}
