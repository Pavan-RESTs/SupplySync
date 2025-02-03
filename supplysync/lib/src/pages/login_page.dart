import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supplysync/core/constants/globla_classes.dart';
import 'package:supplysync/src/bottom_nav_bar.dart';

import '../../../../core/constants/image_strings.dart';
import '../../core/constants/text_strings.dart';
import '../../core/utils/helper_functions.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool isObscured = true;
  bool isLoading = false;
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  void _login() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    // Validate form before attempting login
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      isLoading = true;
    });

    try {
      // Attempt Firebase Authentication
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );
      prefs.setBool('userLoggedIn', true);

      // Navigate to home screen on successful login
      Get.offAll(const BottomNavBar());
    } on FirebaseAuthException catch (e) {
      // Handle specific Firebase authentication errors
      String errorMessage = 'Login failed';
      switch (e.code) {
        case 'invalid-email':
          errorMessage = 'Invalid email address';
          break;
        case 'user-not-found':
          errorMessage = 'No user found with this email';
          break;
        case 'wrong-password':
          errorMessage = 'Incorrect password';
          break;
        case 'user-disabled':
          errorMessage = 'User account has been disabled';
          break;
        default:
          print(e.code);
          print(e.message);
      }
      IHelper.showSnackBar('Login Error', errorMessage);
      // Show error in a snackbar
    } catch (e) {
      IHelper.showSnackBar('Error', 'An unexpected error occurred');
    } finally {
      // Reset loading state
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 33, vertical: 200),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                // Logo
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 93,
                      height: 93,
                      child: Image(
                        image: const AssetImage(
                            IImageStrings.loginPageSafeMateLogo),
                        width: GlobalClasses.screenWidth / 4,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                const Text(
                  ITextStrings.loginPageTitle,
                  style: TextStyle(
                      fontSize: 25,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w800),
                ),
                const Text(
                  ITextStrings.loginPageSubTitle,
                  style: TextStyle(
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w500,
                      fontSize: 22,
                      color: Color.fromRGBO(0, 0, 0, 0.5)),
                ),
                SizedBox(height: GlobalClasses.screenHeight * 0.07),

                // Email TextFormField with validation
                TextFormField(
                  controller: emailController,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: const Color.fromRGBO(247, 248, 249, 1),
                    hintText: ITextStrings.enterYourEmail,
                    hintStyle: const TextStyle(
                        fontSize: 12.3,
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w500,
                        color: Color.fromRGBO(131, 145, 161, 1)),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email';
                    }
                    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                        .hasMatch(value)) {
                      return 'Enter a valid email address';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 15),

                // Password TextFormField with validation
                TextFormField(
                  obscureText: isObscured,
                  controller: passwordController,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: const Color.fromRGBO(247, 248, 249, 1),
                    hintText: ITextStrings.enterYourPassword,
                    suffixIcon: GestureDetector(
                      onTap: () {
                        setState(() {
                          isObscured = !isObscured;
                        });
                      },
                      child: isObscured
                          ? const Icon(Iconsax.eye_slash)
                          : const Icon(Iconsax.eye),
                    ),
                    hintStyle: const TextStyle(
                        fontSize: 12.3,
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w500,
                        color: Color.fromRGBO(131, 145, 161, 1)),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your password';
                    }
                    if (value.length < 6) {
                      return 'Password must be at least 6 characters';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 30),

                // Login Button with loading state
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : _login,
                    child: isLoading
                        ? SpinKitThreeBounce(
                            size: 20,
                            color: Colors.white,
                          )
                        : const Text(
                            ITextStrings.loginText,
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 15,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void show(BuildContext context) {
    final theme = Theme.of(context);

    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        elevation: 8,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          constraints: const BoxConstraints(
            maxWidth: 400,
            maxHeight: 250,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.primaryColor.withOpacity(0.1),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: theme.primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.logout,
                        color: theme.primaryColor,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Logout',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: theme.primaryColor,
                          fontFamily: 'Roboto',
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(
                        Icons.close,
                        color: Colors.grey[600],
                      ),
                      splashRadius: 20,
                    ),
                  ],
                ),
              ),
              // Content
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
                child: Text(
                  'Are you sure you want to log out?',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[800],
                    fontFamily: 'Roboto',
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              // Footer
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(16),
                    bottomRight: Radius.circular(16),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        'Cancel',
                        style: TextStyle(
                          color: theme.primaryColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        Get.offAll(() => const LoginPage());
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.primaryColor,
                      ),
                      child: const Text('Logout'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
