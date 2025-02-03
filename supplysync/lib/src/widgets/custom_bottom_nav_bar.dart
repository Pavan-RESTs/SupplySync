import 'package:flashy_tab_bar2/flashy_tab_bar2.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

class CustomBottomNavBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemSelected;

  const CustomBottomNavBar({
    super.key,
    required this.selectedIndex,
    required this.onItemSelected,
  });

  @override
  Widget build(BuildContext context) {
    return FlashyTabBar(
      shadows: const [BoxShadow(blurRadius: 1)],
      iconSize: 30,
      selectedIndex: selectedIndex,
      showElevation: true,
      onItemSelected: onItemSelected,
      items: [
        FlashyTabBarItem(
          icon: const Icon(
            Iconsax.document_download,
            color: Color(0xff5f66ea),
          ),
          title: Text(
            'Supply',
            style: Theme.of(context)
                .textTheme
                .headlineSmall!
                .apply(fontWeightDelta: -2),
          ),
        ),
        FlashyTabBarItem(
          icon: const Icon(
            Iconsax.document_upload,
            color: Color(0xff5f66ea),
          ),
          title: Text(
            'Retail',
            style: Theme.of(context)
                .textTheme
                .headlineSmall!
                .apply(fontWeightDelta: -2),
          ),
        ),
        FlashyTabBarItem(
          icon: const Icon(
            Iconsax.document_cloud,
            color: Color(0xff5f66ea),
          ),
          title: Text(
            'Account',
            style: Theme.of(context)
                .textTheme
                .headlineSmall!
                .apply(fontWeightDelta: -2),
          ),
        ),
        FlashyTabBarItem(
          icon: const Icon(
            Iconsax.document_code,
            color: Color(0xff5f66ea),
          ),
          title: Text(
            'Data',
            style: Theme.of(context)
                .textTheme
                .headlineSmall!
                .apply(fontWeightDelta: -2),
          ),
        ),
      ],
    );
  }
}
