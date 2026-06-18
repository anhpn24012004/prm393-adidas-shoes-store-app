String formatVnd(num value, {String suffix = ' VND'}) {
  final roundedValue = value.round();
  final sign = roundedValue < 0 ? '-' : '';
  final digits = roundedValue.abs().toString();
  final formatted = digits.replaceAllMapped(
    RegExp(r'\B(?=(\d{3})+(?!\d))'),
    (_) => '.',
  );

  return '$sign$formatted$suffix';
}
