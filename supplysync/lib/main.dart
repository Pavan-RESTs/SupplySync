import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supplysync/core/constants/globla_classes.dart';
import 'package:supplysync/core/theme/theme.dart';
import 'package:supplysync/src/bottom_nav_bar.dart';
import 'package:supplysync/src/pages/login_page.dart';

import 'core/utils/helper_functions.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  SharedPreferences prefs = await SharedPreferences.getInstance();
  bool userLoggedIn = prefs.getBool('userLoggedIn') ?? false;
  print("Login status: $userLoggedIn");
  runApp(App(userLoggedIn: userLoggedIn));
}

class App extends StatelessWidget {
  const App({super.key, required this.userLoggedIn});
  final bool userLoggedIn;

  @override
  Widget build(BuildContext context) {
    GlobalClasses.screenWidth = IHelper.screenWidth(context);
    GlobalClasses.screenHeight = IHelper.screenHeight(context);

    return GetMaterialApp(
      theme: IAppTheme.lightTheme,
      darkTheme: IAppTheme.darkTheme,
      themeMode: ThemeMode.light,
      home: userLoggedIn ? const BottomNavBar() : const LoginPage(),
    );
  }
}
