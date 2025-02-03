import 'package:animated_custom_dropdown/custom_dropdown.dart';
import 'package:flutter/material.dart';
import 'package:supplysync/core/constants/colors.dart';
import 'package:supplysync/core/constants/globla_classes.dart';
import 'package:supplysync/core/constants/sizes.dart';

class CustomDropDownSelectOnly extends StatelessWidget {
  const CustomDropDownSelectOnly({
    super.key,
    required this.names,
    required this.onChanged,
    required this.hintText,
  });

  final List<String> names;
  final String hintText;
  final Function(String) onChanged;

  @override
  Widget build(BuildContext context) {
    // Create a new list with "All" as the first option
    final List<String> itemsWithReset = ['All', ...names];

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(ISizes.inputFieldRadius),
        border: Border.all(color: IColors.grey),
      ),
      height: 55,
      width: GlobalClasses.screenWidth / 1.75,
      child: CustomDropdown<String>.search(
        decoration: const CustomDropdownDecoration(
          expandedFillColor: Colors.white,
          listItemDecoration: ListItemDecoration(
            selectedColor: IColors.grey,
            splashColor: IColors.darkGrey,
            selectedIconShape: CircleBorder(
              side: BorderSide(color: IColors.primary),
            ),
          ),
          noResultFoundStyle: TextStyle(color: IColors.textPrimary),
          headerStyle: TextStyle(color: Colors.black),
          closedSuffixIcon: Icon(
            Icons.sort,
            size: ISizes.iconMd,
            color: Colors.black,
          ),
          expandedSuffixIcon: Icon(
            Icons.sort,
            size: ISizes.iconMd,
            color: Colors.black,
          ),
          closedFillColor: Colors.white,
          hintStyle: TextStyle(
            color: IColors.black,
            fontSize: ISizes.fontSizeSm,
          ),
          listItemStyle: TextStyle(color: IColors.textPrimary),
          searchFieldDecoration: SearchFieldDecoration(
            textStyle: TextStyle(color: Colors.black54),
            hintStyle: TextStyle(color: Colors.black54),
            fillColor: Color(0xfff4f5f8),
            prefixIcon: Icon(
              Icons.search,
              color: Colors.black54,
            ),
          ),
        ),
        hintText: hintText,
        items: itemsWithReset,
        excludeSelected: true,
        onChanged: (value) {
          // If "All" is selected, pass an empty string to reset the selection
          onChanged(value == 'All' ? '' : value!);
        },
      ),
    );
  }
}
