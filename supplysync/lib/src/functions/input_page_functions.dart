import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supplysync/core/constants/colors.dart';

import '../../../../../core/utils/firebase_helper_functions.dart';
import '../pages/login_page.dart';

class InputPageFunctions {
  static List<String> getMapSync(Future<List<Map<dynamic, dynamic>>> data) {
    List<String> names = [];
    data.then((list) {
      for (final map in list) {
        names.add(map['name'] as String);
      }
    });
    return names;
  }

  static void _showDetailDialog(
      BuildContext context, Map<String, dynamic> data) {
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
            maxWidth: 500,
            maxHeight: 600,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
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
                        Icons.description_outlined,
                        color: theme.primaryColor,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Company Profile',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              color: theme.primaryColor,
                              fontFamily: 'Roboto',
                            ),
                          ),
                          if (data['datetime'] != null)
                            Text(
                              data['datetime'].toString(),
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey[600],
                                fontFamily: 'Roboto',
                              ),
                            ),
                        ],
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
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 16,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: data.entries.map((entry) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              entry.key,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.grey[700],
                                fontFamily: 'Roboto',
                              ),
                            ),
                            Text(
                              entry.value.toString(),
                              style: TextStyle(
                                color: Colors.grey[900],
                                fontFamily: 'Roboto',
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 16,
                ),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(16),
                    bottomRight: Radius.circular(16),
                  ),
                ),
                child: Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 8,
                      ),
                      child: Text(
                        'Close',
                        style: TextStyle(
                          color: theme.primaryColor,
                          fontWeight: FontWeight.w500,
                          fontFamily: 'Roboto',
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static List<String> getListSync(Future<List<String>> data) {
    List<String> names = [];
    data.then((list) {
      names = list; // Directly assign the list from the Future
    }).catchError((e) {
      print('Error fetching data: $e');
    });
    return names;
  }

  static Future<Map<dynamic, dynamic>?> getEarliestTransactionDocument() async {
    try {
      // Fetch all documents from 'supplier_transaction' collection
      List<Map<dynamic, dynamic>> data =
          await FireBaseHelperFunctions.getDataFromCollection(
              'supplier_transaction');

      Map<dynamic, dynamic>? earliestDoc;
      DateTime? earliestTime;

      // Iterate through all documents and extract the datetime from the 'datetime' field
      for (var doc in data) {
        if (doc['transaction_status'] == 'active' ||
            doc['transaction_status'] == 'expired') continue;
        try {
          String datetimeStr = doc['datetime']; // ✅ Fetch 'datetime' field
          DateTime transactionDatetime = DateFormat('dd/MM/yyyy HH:mm:ss')
              .parse(datetimeStr); // ✅ Convert to DateTime

          // Compare with the current earliest time
          if (earliestTime == null ||
              transactionDatetime.isBefore(earliestTime)) {
            earliestTime = transactionDatetime;
            earliestDoc = doc;
          }
        } catch (e) {
          print("Skipping document due to datetime parsing error: $e");
        }
      }

      // ✅ Return the document with the earliest datetime or null if no valid documents exist
      return earliestDoc;
    } catch (e) {
      print("Error fetching earliest transaction document: $e");
      return null; // Return null if there was an error
    }
  }

  static void showLogoutConfirmationDialog(BuildContext context) {
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
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white70,
                      ),
                      child: Text(
                        'Cancel',
                        style: TextStyle(
                          fontSize: 13,
                          color: IColors.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Container(
                      width: 70,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: () async {
                          SharedPreferences prefs =
                              await SharedPreferences.getInstance();
                          prefs.setBool('userLoggedIn', false);
                          Get.offAll(() => const LoginPage());
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.primaryColor,
                        ),
                        child: Text(
                          'Logout',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
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
