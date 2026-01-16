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

  double toHours() => inMinutes / 60.0;
}
