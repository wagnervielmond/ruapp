import 'package:flutter/material.dart';
import 'colors.dart';
import 'text_styles.dart';

class AppTheme {
  // Light Theme
  static ThemeData get lightTheme {
    return ThemeData(
      // Color Scheme
      colorScheme: const ColorScheme.light(
        primary: AppColors.primary,
        onPrimary: AppColors.white,
        primaryContainer: AppColors.primaryContainer,
        onPrimaryContainer: AppColors.primaryDark,

        secondary: AppColors.secondary,
        onSecondary: AppColors.white,
        secondaryContainer: AppColors.secondaryContainer,
        onSecondaryContainer: AppColors.secondaryDark,

        background: AppColors.background,
        onBackground: AppColors.onBackground,

        surface: AppColors.surface,
        onSurface: AppColors.onSurface,

        error: AppColors.error,
        onError: AppColors.white,
        errorContainer: AppColors.errorLight,
        onErrorContainer: AppColors.errorDark,

        surfaceVariant: AppColors.gray100,
        onSurfaceVariant: AppColors.textSecondary,

        outline: AppColors.borderLight,
        outlineVariant: AppColors.borderMedium,

        shadow: AppColors.shadowLight,
        scrim: AppColors.overlayDark,
      ),

      // Text Theme - Usando métodos para criar os estilos
      textTheme: _buildLightTextTheme(),

      // Primary Text Theme - Criado via método
      primaryTextTheme: _buildPrimaryTextTheme(),

      // App Bar Theme
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        elevation: 2,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          height: 1.2,
          letterSpacing: 0.15,
          color: AppColors.white,
        ),
        iconTheme: IconThemeData(color: AppColors.white, size: 24),
        actionsIconTheme: IconThemeData(color: AppColors.white, size: 24),
        surfaceTintColor: AppColors.transparent,
      ),

      // Bottom App Bar Theme
      bottomAppBarTheme: const BottomAppBarTheme(
        color: AppColors.surface,
        elevation: 8,
        surfaceTintColor: AppColors.transparent,
        shadowColor: AppColors.shadowMedium,
      ),

      // Bottom Navigation Bar Theme
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.surface,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textSecondary,
        selectedLabelStyle: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
        unselectedLabelStyle: TextStyle(fontSize: 12, fontWeight: FontWeight.w400),
        elevation: 8,
        type: BottomNavigationBarType.fixed,
        showSelectedLabels: true,
        showUnselectedLabels: true,
      ),

      // Button Themes
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.white,
          disabledBackgroundColor: AppColors.gray300,
          disabledForegroundColor: AppColors.gray500,
          textStyle: AppTextStyles.buttonMedium,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 2,
          shadowColor: AppColors.shadowMedium,
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          textStyle: AppTextStyles.buttonMedium,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          textStyle: AppTextStyles.buttonMedium,
          side: const BorderSide(color: AppColors.primary, width: 1),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),

      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.white,
        contentPadding: const EdgeInsets.all(16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.borderLight),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.borderLight),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.error, width: 2),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.borderLight),
        ),
        labelStyle: AppTextStyles.inputLabel,
        hintStyle: AppTextStyles.hintText,
        errorStyle: AppTextStyles.errorText,
        helperStyle: AppTextStyles.bodySmall,
        prefixStyle: AppTextStyles.bodyMedium,
        suffixStyle: AppTextStyles.bodyMedium,
        counterStyle: AppTextStyles.bodySmall,
      ),

      // Card Theme
      cardTheme: CardThemeData(
        color: AppColors.surface,
        surfaceTintColor: AppColors.transparent,
        elevation: 2,
        shadowColor: AppColors.shadowLight,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.borderLight, width: 1),
        ),
        margin: EdgeInsets.zero,
      ),

      // Dialog Theme
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.surface,
        surfaceTintColor: AppColors.transparent,
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        titleTextStyle: AppTextStyles.titleLarge,
        contentTextStyle: AppTextStyles.bodyMedium,
      ),

      // Chip Theme
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.gray100,
        disabledColor: AppColors.gray200,
        selectedColor: AppColors.primary,
        secondarySelectedColor: AppColors.primaryContainer,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        labelStyle: AppTextStyles.labelMedium,
        secondaryLabelStyle: AppTextStyles.labelMedium.copyWith(color: AppColors.white),
        brightness: Brightness.light,
        elevation: 0,
        side: const BorderSide(color: AppColors.borderLight),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),

      // Divider Theme
      dividerTheme: const DividerThemeData(
        color: AppColors.borderLight,
        thickness: 1,
        space: 16,
      ),

      // Progress Indicator Theme
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.primary,
        linearTrackColor: AppColors.gray200,
        circularTrackColor: AppColors.gray200,
      ),

      // SnackBar Theme
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.gray800,
        actionTextColor: AppColors.secondary,
        disabledActionTextColor: AppColors.gray400,
        contentTextStyle: AppTextStyles.bodyMedium.copyWith(color: AppColors.white),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        behavior: SnackBarBehavior.floating,
        elevation: 6,
      ),

      // Popup Menu Theme
      popupMenuTheme: PopupMenuThemeData(
        color: AppColors.surface,
        surfaceTintColor: AppColors.transparent,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: AppColors.borderLight),
        ),
        textStyle: AppTextStyles.bodyMedium,
      ),

      // Navigation Rail Theme
      navigationRailTheme: const NavigationRailThemeData(
        backgroundColor: AppColors.surface,
        elevation: 2,
        selectedIconTheme: IconThemeData(color: AppColors.primary, size: 24),
        unselectedIconTheme: IconThemeData(color: AppColors.textSecondary, size: 24),
        selectedLabelTextStyle: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w500),
        unselectedLabelTextStyle: TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.w400),
      ),

      // Material 3
      useMaterial3: true,
      visualDensity: VisualDensity.standard,
      applyElevationOverlayColor: false,
    );
  }

  // Dark Theme
  static ThemeData get darkTheme {
    return ThemeData(
      // Color Scheme
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primaryLight,
        onPrimary: AppColors.white,
        primaryContainer: AppColors.primaryDark,
        onPrimaryContainer: AppColors.primaryLight,

        secondary: AppColors.secondaryLight,
        onSecondary: AppColors.gray900,
        secondaryContainer: AppColors.secondaryDark,
        onSecondaryContainer: AppColors.secondaryLight,

        background: AppColors.gray900,
        onBackground: AppColors.gray100,

        surface: AppColors.gray800,
        onSurface: AppColors.gray100,

        error: AppColors.errorLight,
        onError: AppColors.gray900,
        errorContainer: AppColors.errorDark,
        onErrorContainer: AppColors.errorLight,

        surfaceVariant: AppColors.gray700,
        onSurfaceVariant: AppColors.gray300,

        outline: AppColors.gray600,
        outlineVariant: AppColors.gray500,

        shadow: AppColors.black,
        scrim: AppColors.overlayDark,
      ),

      // Text Theme para dark
      textTheme: _buildDarkTextTheme(),

      // App Bar Theme para Dark
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.gray900,
        foregroundColor: AppColors.gray100,
        elevation: 2,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          height: 1.2,
          letterSpacing: 0.15,
          color: AppColors.gray100,
        ),
        iconTheme: IconThemeData(color: AppColors.gray100, size: 24),
        actionsIconTheme: IconThemeData(color: AppColors.gray100, size: 24),
      ),

      // Input Decoration Theme para Dark
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.gray800,
        contentPadding: const EdgeInsets.all(16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.gray600),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.gray600),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primaryLight, width: 2),
        ),
        labelStyle: AppTextStyles.inputLabel.copyWith(color: AppColors.gray300),
        hintStyle: AppTextStyles.hintText.copyWith(color: AppColors.gray400),
      ),

      // Card Theme para Dark
      cardTheme: CardThemeData(
        color: AppColors.gray800,
        surfaceTintColor: AppColors.transparent,
        elevation: 2,
        shadowColor: AppColors.black,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.gray700, width: 1),
        ),
      ),

      // Use Material 3
      useMaterial3: true,
    );
  }

  // Métodos auxiliares para construir os text themes
  static TextTheme _buildLightTextTheme() {
    return const TextTheme(
      displayLarge: TextStyle(
        fontSize: 57,
        fontWeight: FontWeight.w400,
        height: 1.12,
        letterSpacing: -0.25,
        color: AppColors.textPrimary,
      ),
      displayMedium: TextStyle(
        fontSize: 45,
        fontWeight: FontWeight.w400,
        height: 1.16,
        letterSpacing: 0,
        color: AppColors.textPrimary,
      ),
      displaySmall: TextStyle(
        fontSize: 36,
        fontWeight: FontWeight.w400,
        height: 1.22,
        letterSpacing: 0,
        color: AppColors.textPrimary,
      ),
      headlineLarge: TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.w400,
        height: 1.25,
        letterSpacing: 0,
        color: AppColors.textPrimary,
      ),
      headlineMedium: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.w400,
        height: 1.29,
        letterSpacing: 0,
        color: AppColors.textPrimary,
      ),
      headlineSmall: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w400,
        height: 1.33,
        letterSpacing: 0,
        color: AppColors.textPrimary,
      ),
      titleLarge: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w500,
        height: 1.27,
        letterSpacing: 0,
        color: AppColors.textPrimary,
      ),
      titleMedium: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w500,
        height: 1.33,
        letterSpacing: 0.15,
        color: AppColors.textPrimary,
      ),
      titleSmall: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        height: 1.43,
        letterSpacing: 0.1,
        color: AppColors.textPrimary,
      ),
      bodyLarge: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        height: 1.5,
        letterSpacing: 0.5,
        color: AppColors.textPrimary,
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        height: 1.43,
        letterSpacing: 0.25,
        color: AppColors.textPrimary,
      ),
      bodySmall: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        height: 1.33,
        letterSpacing: 0.4,
        color: AppColors.textPrimary,
      ),
      labelLarge: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        height: 1.43,
        letterSpacing: 0.1,
        color: AppColors.textPrimary,
      ),
      labelMedium: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        height: 1.33,
        letterSpacing: 0.5,
        color: AppColors.textPrimary,
      ),
      labelSmall: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        height: 1.45,
        letterSpacing: 0.5,
        color: AppColors.textPrimary,
      ),
    );
  }

  static TextTheme _buildPrimaryTextTheme() {
    return TextTheme(
      displayLarge: AppTextStyles.displayLarge.copyWith(color: AppColors.white),
      displayMedium: AppTextStyles.displayMedium.copyWith(color: AppColors.white),
      displaySmall: AppTextStyles.displaySmall.copyWith(color: AppColors.white),
      headlineLarge: AppTextStyles.headlineLarge.copyWith(color: AppColors.white),
      headlineMedium: AppTextStyles.headlineMedium.copyWith(color: AppColors.white),
      headlineSmall: AppTextStyles.headlineSmall.copyWith(color: AppColors.white),
      titleLarge: AppTextStyles.titleLarge.copyWith(color: AppColors.white),
      titleMedium: AppTextStyles.titleMedium.copyWith(color: AppColors.white),
      titleSmall: AppTextStyles.titleSmall.copyWith(color: AppColors.white),
      bodyLarge: AppTextStyles.bodyLarge.copyWith(color: AppColors.white),
      bodyMedium: AppTextStyles.bodyMedium.copyWith(color: AppColors.white),
      bodySmall: AppTextStyles.bodySmall.copyWith(color: AppColors.white),
      labelLarge: AppTextStyles.labelLarge.copyWith(color: AppColors.white),
      labelMedium: AppTextStyles.labelMedium.copyWith(color: AppColors.white),
      labelSmall: AppTextStyles.labelSmall.copyWith(color: AppColors.white),
    );
  }

  static TextTheme _buildDarkTextTheme() {
    return TextTheme(
      displayLarge: AppTextStyles.displayLarge.copyWith(color: AppColors.gray100),
      displayMedium: AppTextStyles.displayMedium.copyWith(color: AppColors.gray100),
      displaySmall: AppTextStyles.displaySmall.copyWith(color: AppColors.gray100),
      headlineLarge: AppTextStyles.headlineLarge.copyWith(color: AppColors.gray100),
      headlineMedium: AppTextStyles.headlineMedium.copyWith(color: AppColors.gray100),
      headlineSmall: AppTextStyles.headlineSmall.copyWith(color: AppColors.gray100),
      titleLarge: AppTextStyles.titleLarge.copyWith(color: AppColors.gray100),
      titleMedium: AppTextStyles.titleMedium.copyWith(color: AppColors.gray100),
      titleSmall: AppTextStyles.titleSmall.copyWith(color: AppColors.gray100),
      bodyLarge: AppTextStyles.bodyLarge.copyWith(color: AppColors.gray200),
      bodyMedium: AppTextStyles.bodyMedium.copyWith(color: AppColors.gray200),
      bodySmall: AppTextStyles.bodySmall.copyWith(color: AppColors.gray300),
      labelLarge: AppTextStyles.labelLarge.copyWith(color: AppColors.gray200),
      labelMedium: AppTextStyles.labelMedium.copyWith(color: AppColors.gray300),
      labelSmall: AppTextStyles.labelSmall.copyWith(color: AppColors.gray400),
    );
  }

  // Custom theme extensions
  static ThemeData getTheme({bool isDark = false}) {
    return isDark ? darkTheme : lightTheme;
  }

  // Helper method to get responsive text theme
  static TextTheme responsiveTextTheme(BuildContext context, {bool isDark = false}) {
    final baseTheme = isDark ? darkTheme.textTheme : lightTheme.textTheme;
    final scale = MediaQuery.of(context).textScaleFactor;

    return baseTheme.copyWith(
      displayLarge: baseTheme.displayLarge?.copyWith(fontSize: baseTheme.displayLarge!.fontSize! * scale),
      displayMedium: baseTheme.displayMedium?.copyWith(fontSize: baseTheme.displayMedium!.fontSize! * scale),
      displaySmall: baseTheme.displaySmall?.copyWith(fontSize: baseTheme.displaySmall!.fontSize! * scale),
      headlineLarge: baseTheme.headlineLarge?.copyWith(fontSize: baseTheme.headlineLarge!.fontSize! * scale),
      headlineMedium: baseTheme.headlineMedium?.copyWith(fontSize: baseTheme.headlineMedium!.fontSize! * scale),
      headlineSmall: baseTheme.headlineSmall?.copyWith(fontSize: baseTheme.headlineSmall!.fontSize! * scale),
      titleLarge: baseTheme.titleLarge?.copyWith(fontSize: baseTheme.titleLarge!.fontSize! * scale),
      titleMedium: baseTheme.titleMedium?.copyWith(fontSize: baseTheme.titleMedium!.fontSize! * scale),
      titleSmall: baseTheme.titleSmall?.copyWith(fontSize: baseTheme.titleSmall!.fontSize! * scale),
    );
  }
}