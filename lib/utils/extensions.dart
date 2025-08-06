extension StringExtensions on String {
  String toProperCase() {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1).toLowerCase()}';
  }

  String normalizePostalCode() {
    return replaceAll(' ', '').toUpperCase();
  }

  bool isDutchPostalCode() {
    return RegExp(r'^\d{4}[A-Za-z]{2}$').hasMatch(normalizePostalCode());
  }
}

extension DateTimeExtensions on DateTime {
  String toTimeString() {
    return '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
  }

  String toDateString() {
    return '${day.toString().padLeft(2, '0')}-${month.toString().padLeft(2, '0')}-$year';
  }
}
