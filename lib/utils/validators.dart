import '../utils/extensions.dart';

class Validators {
  static String? validateAddress(String? value) {
    if (value == null || value.isEmpty) {
      return 'Address is required';
    }
    if (value.length < 10) {
      return 'Address is too short';
    }
    return null;
  }

  static String? validatePostalCode(String? value) {
    if (value == null || value.isEmpty) {
      return 'Postal code is required';
    }
    if (!value.isDutchPostalCode()) {
      return 'Invalid Dutch postal code format';
    }
    return null;
  }

  static String? validateDeliveryTime(DateTime? time, bool isAsap) {
    if (!isAsap && time == null) {
      return 'Delivery time is required';
    }
    if (time != null && time.isBefore(DateTime.now())) {
      return 'Delivery time cannot be in the past';
    }
    return null;
  }
}
