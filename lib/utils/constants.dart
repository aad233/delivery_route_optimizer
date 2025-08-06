class AppConstants {
  static const String appName = 'Delivery Route Optimizer';
  static const String restaurantAddress =
      'Wolphaertsbocht 276A, 3081 KR Rotterdam';
  static const String restaurantPostal = '3081KR';
  static const double mapPadding = 50.0;

  // Time constants
  static const int defaultDeliveryWindow = 30; // minutes
  static const int maxAsapDeliveryTime = 45; // minutes

  // Text recognition constants
  static const List<String> addressKeywords = [
    'straat',
    'laan',
    'weg',
    'plein',
    'park',
    'singel',
    'kade',
    'dijk',
    'steeg',
    'hof'
  ];

  static const List<String> postalCodePatterns = [
    r'\d{4}\s?[A-Za-z]{2}',
    r'\d{4}[A-Za-z]{2}',
  ];
}
