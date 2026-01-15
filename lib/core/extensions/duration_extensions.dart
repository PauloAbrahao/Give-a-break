extension DurationExtensions on Duration {
  String toReadableString() {
    final hours = inHours;
    final minutes = inMinutes.remainder(60);

    if (hours > 0) {
      if (minutes > 0) {
        return '${hours}h ${minutes}m';
      }
      return '${hours}h';
    }

    if (minutes > 0) {
      return '${minutes}m';
    }

    final seconds = inSeconds.remainder(60);
    if (seconds > 0) {
      return '${seconds}s';
    }

    return '0m';
  }

  String toShortString() {
    final hours = inHours;
    final minutes = inMinutes.remainder(60);

    if (hours > 0) {
      return '${hours}h ${minutes}m';
    }
    return '${minutes}m';
  }

  String toFullString() {
    final hours = inHours;
    final minutes = inMinutes.remainder(60);
    final seconds = inSeconds.remainder(60);

    final parts = <String>[];
    if (hours > 0) parts.add('$hours hour${hours != 1 ? 's' : ''}');
    if (minutes > 0) parts.add('$minutes minute${minutes != 1 ? 's' : ''}');
    if (seconds > 0 && hours == 0) {
      parts.add('$seconds second${seconds != 1 ? 's' : ''}');
    }

    if (parts.isEmpty) return '0 minutes';
    return parts.join(' ');
  }

  double toHours() => inMinutes / 60.0;
}
