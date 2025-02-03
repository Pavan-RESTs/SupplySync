import 'package:flutter/material.dart';
import 'package:supplysync/core/constants/enums.dart';
import 'package:supplysync/core/constants/globla_classes.dart';

class PopupMenuOptions extends StatefulWidget {
  final Function(SampleItem) onItemSelected;

  const PopupMenuOptions({super.key, required this.onItemSelected});

  @override
  State<PopupMenuOptions> createState() => _PopupMenuOptionsState();
}

class _PopupMenuOptionsState extends State<PopupMenuOptions> {
  SampleItem? selectedItem = SampleItem.supply;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<SampleItem>(
      iconSize: GlobalClasses.screenWidth / 14,
      color: Colors.white,
      iconColor: Colors.white,
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      initialValue: GlobalClasses.currentIndex,
      onSelected: (SampleItem item) {
        setState(() {
          widget.onItemSelected(item);
          selectedItem = item;
        });
      },
      itemBuilder: (BuildContext context) => <PopupMenuEntry<SampleItem>>[
        _buildMenuItem(SampleItem.supply, 'Supply', context),
        _buildMenuItem(SampleItem.retail, 'Retail', context),
        _buildMenuItem(SampleItem.account, 'Account', context),
      ],
    );
  }

  PopupMenuItem<SampleItem> _buildMenuItem(
      SampleItem value, String text, BuildContext context) {
    return PopupMenuItem<SampleItem>(
      value: value,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            text,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}
