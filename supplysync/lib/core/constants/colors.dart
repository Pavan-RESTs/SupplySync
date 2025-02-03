import 'package:flutter/material.dart';

class IColors {
  // App theme colors
  static const Color primary = Color(
      0xFF3D5AFE); // A deeper blue for a more professional and serious tone.
  static const Color secondary =
      Color(0xFF8E8E93); // A subtle neutral shade, soft but still impactful.
  static const Color accent =
      Color(0xFF81C784); // A muted green accent to represent growth or success.

  // Text colors
  static const Color textPrimary = Color(
      0xFF212121); // Darker, almost charcoal for primary text. More professional than a pure black.
  static const Color textSecondary = Color(
      0xFF757575); // A softer gray for secondary text or less important information.
  static const Color textWhite =
      Colors.white; // Clean, clear white for contrast.

  // Background colors
  static const Color light = Color(
      0xFFF5F5F5); // A soft light gray background, easier on the eyes than pure white.
  static const Color dark = Color(
      0xFF424242); // A darker gray for a professional, polished look for certain sections or dialogs.
  static const Color primaryBackground = Color(
      0xFFF1F8E9); // A light greenish tint for a soothing background without being too bright.

  // Background Container colors
  static const Color lightContainer =
      Color(0xFFF5F5F5); // Subtle light gray for content containers.
  static Color darkContainer = IColors.white.withOpacity(
      0.1); // Slightly transparent white for dark containers to add depth.

  // Button colors
  static const Color buttonPrimary = Color(
      0xFF3D5AFE); // Matches primary color for main call-to-action buttons.
  static const Color buttonSecondary = Color(
      0xFF757575); // Soft gray for secondary buttons, ensuring they are noticeable but not too bold.
  static const Color buttonDisabled = Color(
      0xFFC1C1C1); // Light gray for disabled buttons, indicating inactivity.

  // Border colors
  static const Color borderPrimary =
      Color(0xFFE0E0E0); // Light gray for borders, clean and unobtrusive.
  static const Color borderSecondary = Color(
      0xFFBDBDBD); // Slightly darker gray for secondary borders, adding depth.

  // Error and validation colors
  static const Color error = Color(
      0xFFD32F2F); // Bold red for error, easily noticeable for warnings or issues.
  static const Color success =
      Color(0xFF388E3C); // A strong green for success messages or validation.
  static const Color warning =
      Color(0xFFFBC02D); // A muted yellow for warnings, soft but still visible.
  static const Color info =
      Color(0xFF1976D2); // A classic blue for information messages.

  // Neutral Shades
  static const Color black =
      Color(0xFF212121); // Slightly softer black, easier on the eyes.
  static const Color darkerGrey = Color(
      0xFF616161); // A darker, refined gray for specific use cases like headers.
  static const Color darkGrey =
      Color(0xFF9E9E9E); // Medium gray for less prominent text.
  static const Color grey =
      Color(0xFFBDBDBD); // Lighter gray for borders or muted elements.
  static const Color softGrey =
      Color(0xFFEEEEEE); // Subtle, soft gray for background components.
  static const Color lightGrey =
      Color(0xFFF1F1F1); // Very light gray for large background areas.
  static const Color white =
      Color(0xFFFFFFFF); // Pure white for maximum contrast when needed.
}
