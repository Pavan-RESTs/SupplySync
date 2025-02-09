import 'package:flutter/material.dart';
import 'package:supplysync/core/theme/widget_themes/appbar_theme.dart';
import 'package:supplysync/core/theme/widget_themes/bottom_sheet_theme.dart';
import 'package:supplysync/core/theme/widget_themes/checkbox_theme.dart';
import 'package:supplysync/core/theme/widget_themes/elevated_button_theme.dart';
import 'package:supplysync/core/theme/widget_themes/outlined_button_theme.dart';
import 'package:supplysync/core/theme/widget_themes/text_field_theme.dart';
import 'package:supplysync/core/theme/widget_themes/text_selection_theme.dart';
import 'package:supplysync/core/theme/widget_themes/text_theme.dart';

import '../constants/colors.dart';

class IAppTheme {
  IAppTheme._();

  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    fontFamily: 'Poppins',
    disabledColor: IColors.grey,
    brightness: Brightness.light,
    primaryColor: IColors.primary,
    textTheme: ITextTheme.lightTextTheme,
    scaffoldBackgroundColor: IColors.white,
    appBarTheme: IAppBarTheme.lightAppBarTheme,
    checkboxTheme: ICheckboxTheme.lightCheckboxTheme,
    bottomSheetTheme: IBottomSheetTheme.lightBottomSheetTheme,
    elevatedButtonTheme: IElevatedButtonTheme.lightElevatedButtonTheme,
    outlinedButtonTheme: IOutlinedButtonTheme.lightOutlinedButtonTheme,
    inputDecorationTheme: ITextFormFieldTheme.lightInputDecorationTheme,
    textSelectionTheme: ITextSelectionTheme.lightTextSelectionTheme,
  );

  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    fontFamily: 'Poppins',
    disabledColor: IColors.grey,
    brightness: Brightness.dark,
    primaryColor: IColors.primary,
    textTheme: ITextTheme.darkTextTheme,
    scaffoldBackgroundColor: IColors.black,
    appBarTheme: IAppBarTheme.darkAppBarTheme,
    checkboxTheme: ICheckboxTheme.darkCheckboxTheme,
    bottomSheetTheme: IBottomSheetTheme.darkBottomSheetTheme,
    elevatedButtonTheme: IElevatedButtonTheme.darkElevatedButtonTheme,
    outlinedButtonTheme: IOutlinedButtonTheme.darkOutlinedButtonTheme,
    inputDecorationTheme: ITextFormFieldTheme.darkInputDecorationTheme,
    textSelectionTheme: ITextSelectionTheme.darkTextSelectionTheme,
  );
}
