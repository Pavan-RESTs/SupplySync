import 'package:flutter/material.dart';
import 'package:supplysync/src/pages/account_form.dart';
import 'package:supplysync/src/pages/data_page.dart';
import 'package:supplysync/src/pages/retailer_form.dart';
import 'package:supplysync/src/pages/supplier_form.dart';
import 'package:supplysync/src/widgets/custom_bottom_nav_bar.dart';

class BottomNavBar extends StatefulWidget {
  const BottomNavBar({super.key});

  @override
  State<BottomNavBar> createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  List<Widget> pages = [
    SupplierForm(),
    RetailerForm(),
    AccountForm(),
    DataPage(),
  ];
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: pages[_selectedIndex],
      bottomNavigationBar: CustomBottomNavBar(
        selectedIndex: _selectedIndex,
        onItemSelected: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
    );
  }
}
