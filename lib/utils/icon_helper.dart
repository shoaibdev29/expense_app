import 'package:flutter/material.dart';

/// Resolves a stored Material icon code point to a constant [IconData].
///
/// Flutter's release icon tree-shaker requires [IconData] instances to be
/// compile-time constants. Look up from this map instead of constructing
/// `IconData(codePoint)` at runtime.
IconData materialIcon(int codePoint) {
  return kCategoryIconsByCodePoint[codePoint] ?? Icons.help_outline;
}

const List<IconData> kCategoryIcons = [
  Icons.restaurant_rounded,
  Icons.directions_car_rounded,
  Icons.shopping_bag_rounded,
  Icons.receipt_long_rounded,
  Icons.favorite_rounded,
  Icons.movie_rounded,
  Icons.school_rounded,
  Icons.payments_rounded,
  Icons.laptop_mac_rounded,
  Icons.storefront_rounded,
  Icons.card_giftcard_rounded,
  Icons.home_rounded,
  Icons.flight_rounded,
  Icons.pets_rounded,
  Icons.sports_esports_rounded,
  Icons.more_horiz_rounded,
  Icons.help_outline,
];

final Map<int, IconData> kCategoryIconsByCodePoint = {
  for (final icon in kCategoryIcons) icon.codePoint: icon,
};
