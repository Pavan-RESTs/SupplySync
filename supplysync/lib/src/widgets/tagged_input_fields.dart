import 'package:flutter/material.dart';
import 'package:supplysync/core/constants/globla_classes.dart';

class TaggedInputFields extends StatelessWidget {
  const TaggedInputFields(
      {super.key, required this.title, required this.controllers});

  final String title;
  final List<TextEditingController> controllers;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context)
              .textTheme
              .headlineLarge!
              .apply(fontWeightDelta: -4),
        ),
        SizedBox(height: GlobalClasses.screenHeight / 50),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            for (var controller in controllers)
              SizedBox(
                width: GlobalClasses.screenWidth / 3.7,
                child: TextFormField(
                  controller: controller,
                  decoration: InputDecoration(
                      hintText: controller == controllers[0]
                          ? "Small"
                          : controller == controllers[1]
                              ? "Medium"
                              : "Large"),
                ),
              ),
          ],
        ),
        SizedBox(height: GlobalClasses.screenHeight / 30),
      ],
    );
  }
}
