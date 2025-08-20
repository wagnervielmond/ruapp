import 'package:flutter/material.dart';

class AppColors {
  // Primary Colors
  static const Color primary = Color(0xFF0053A0);
  static const Color primaryDark = Color(0xFF003A6F);
  static const Color primaryLight = Color(0xFF4D7EBF);
  static const Color primaryContainer = Color(0xFFD8E6F5);

  // Secondary Colors
  static const Color secondary = Color(0xFF00CC66);
  static const Color secondaryDark = Color(0xFF00994D);
  static const Color secondaryLight = Color(0xFF66FF99);
  static const Color secondaryContainer = Color(0xFFE6F9EF);

  // Neutral Colors
  static const Color black = Color(0xFF000000);
  static const Color white = Color(0xFFFFFFFF);
  static const Color transparent = Color(0x00000000);

  // Gray Scale
  static const Color gray50 = Color(0xFFFAFAFA);
  static const Color gray100 = Color(0xFFF5F5F5);
  static const Color gray200 = Color(0xFFEEEEEE);
  static const Color gray300 = Color(0xFFE0E0E0);
  static const Color gray400 = Color(0xFFBDBDBD);
  static const Color gray500 = Color(0xFF9E9E9E);
  static const Color gray600 = Color(0xFF757575);
  static const Color gray700 = Color(0xFF616161);
  static const Color gray800 = Color(0xFF424242);
  static const Color gray900 = Color(0xFF212121);

  // Semantic Colors
  static const Color success = Color(0xFF28A745);
  static const Color successLight = Color(0xFFD4EDDA);
  static const Color successDark = Color(0xFF1E7E34);

  static const Color warning = Color(0xFFFFC107);
  static const Color warningLight = Color(0xFFFFF3CD);
  static const Color warningDark = Color(0xFFE0A800);

  static const Color error = Color(0xFFDC3545);
  static const Color errorLight = Color(0xFFF8D7DA);
  static const Color errorDark = Color(0xFFC82333);

  static const Color info = Color(0xFF17A2B8);
  static const Color infoLight = Color(0xFFD1ECF1);
  static const Color infoDark = Color(0xFF138496);

  // Background Colors
  static const Color background = Color(0xFFF8F9FA);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color onBackground = Color(0xFF212121);
  static const Color onSurface = Color(0xFF212121);

  // Text Colors
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textDisabled = Color(0xFF9E9E9E);
  static const Color textInverse = Color(0xFFFFFFFF);

  // Border Colors
  static const Color borderLight = Color(0xFFEEEEEE);
  static const Color borderMedium = Color(0xFFE0E0E0);
  static const Color borderDark = Color(0xFFBDBDBD);

  // Overlay Colors
  static const Color overlayLight = Color(0x0D000000); // 5%
  static const Color overlayMedium = Color(0x1A000000); // 10%
  static const Color overlayDark = Color(0x33000000); // 20%

  // Shadow Colors
  static const Color shadowLight = Color(0x0D000000);
  static const Color shadowMedium = Color(0x1A000000);
  static const Color shadowDark = Color(0x33000000);

  // Gradient Colors
  static const Gradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primary, primaryDark],
  );

  static const Gradient secondaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [secondary, secondaryDark],
  );

  static const Gradient successGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [success, successDark],
  );

  // State Colors
  static const Color hover = Color(0x0A0053A0); // 4% primary
  static const Color focus = Color(0x1A0053A0); // 10% primary
  static const Color pressed = Color(0x330053A0); // 20% primary
  static const Color dragged = Color(0x0F0053A0); // 6% primary

  // Special Colors
  static const Color shimmerBase = Color(0xFFE0E0E0);
  static const Color shimmerHighlight = Color(0xFFF5F5F5);

  // Social Colors
  static const Color google = Color(0xFFDB4437);
  static const Color facebook = Color(0xFF4267B2);
  static const Color apple = Color(0xFF000000);

  // Utility Methods
  static Color withOpacity(Color color, double opacity) {
    return color.withOpacity(opacity);
  }

  static Color darken(Color color, [double amount = 0.1]) {
    assert(amount >= 0 && amount <= 1);

    final hsl = HSLColor.fromColor(color);
    final hslDark = hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0));

    return hslDark.toColor();
  }

  static Color lighten(Color color, [double amount = 0.1]) {
    assert(amount >= 0 && amount <= 1);

    final hsl = HSLColor.fromColor(color);
    final hslLight = hsl.withLightness((hsl.lightness + amount).clamp(0.0, 1.0));

    return hslLight.toColor();
  }

  // Theme Extensions
  static MaterialColor get primarySwatch => MaterialColor(primary.value, {
    50: Color(0xFFE8F5FF),
    100: Color(0xFFD1EBFF),
    200: Color(0xFF9CD2FF),
    300: Color(0xFF67B9FF),
    400: Color(0xFF329FFF),
    500: primary,
    600: Color(0xFF00458A),
    700: Color(0xFF003874),
    800: Color(0xFF002A5E),
    900: Color(0xFF001C48),
  });
}