import 'package:animated_custom_dropdown/custom_dropdown.dart';
import 'package:flutter/material.dart';
import 'package:supplysync/core/constants/colors.dart';
import 'package:supplysync/core/constants/globla_classes.dart';
import 'package:supplysync/core/constants/sizes.dart';

class CustomDropDown extends StatelessWidget {
  const CustomDropDown({
    super.key,
    required this.names,
    required this.onChanged,
    required this.hintText,
    this.actionIcon = const Icon(
      Icons.corporate_fare_outlined,
      size: 24,
      color: Colors.black,
    ),
  });
  final Icon actionIcon;
  final List<String> names;
  final String hintText;

  final Function(String) onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(ISizes.inputFieldRadius),
        border: Border.all(color: IColors.grey),
      ),
      height: 55,
      width: GlobalClasses.screenWidth / 1.75,
      child: CustomDropdown<String>.search(
        decoration: CustomDropdownDecoration(
          expandedFillColor: Colors.white,
          listItemDecoration: const ListItemDecoration(
            selectedColor: IColors.grey,
            splashColor: IColors.darkGrey,
            selectedIconShape: CircleBorder(
              side: BorderSide(color: IColors.primary),
            ),
          ),
          noResultFoundStyle: const TextStyle(color: IColors.textPrimary),
          headerStyle: const TextStyle(color: Colors.black),
          closedSuffixIcon: actionIcon,
          expandedSuffixIcon: actionIcon,
          closedFillColor: Colors.white,
          hintStyle: const TextStyle(
            color: IColors.black,
            fontSize: ISizes.fontSizeSm,
          ),
          listItemStyle: const TextStyle(color: IColors.textPrimary),
          searchFieldDecoration: const SearchFieldDecoration(
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
        items: names,
        excludeSelected: true,
        onChanged: (value) {
          onChanged(value!);
        },
      ),
    );
  }
}
