import 'package:flutter/material.dart';

import '../../../../../core/constants/colors.dart';

class CustomQuantityCard extends StatelessWidget {
  const CustomQuantityCard({
    super.key,
    required this.type,
    required this.quantity,
    required this.imagePath,
    this.backgroundColor,
    this.borderColor,
    this.width,
    this.height,
  });

  final String type;
  final String quantity;
  final String imagePath;
  final Color? backgroundColor;
  final Color? borderColor;
  final double? width;
  final double? height;

  @override
  Widget build(BuildContext context) {
    // Get screen size for responsive calculations
    final screenSize = MediaQuery.of(context).size;

    // Calculate responsive dimensions
    final cardWidth = width ?? screenSize.width * 0.28;
    final cardHeight = height ?? screenSize.height * 0.08;
    final iconSize = cardHeight * 0.5;

    return Container(
      width: cardWidth,
      height: cardHeight,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            backgroundColor ?? Colors.white,
            backgroundColor?.withOpacity(0.9) ?? Colors.grey[50]!,
          ],
        ),
        borderRadius: BorderRadius.circular(cardHeight * 0.17),
        border: Border.all(
          color: borderColor ?? const Color(0xffaaa7a7),
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(cardHeight * 0.17),
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: cardWidth * 0.08,
            vertical: cardHeight * 0.16,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Icon container with hover effect
              Container(
                width: iconSize,
                height: iconSize,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                ),
                padding: EdgeInsets.all(cardWidth * 0.02),
                child: Image.asset(
                  imagePath,
                  fit: BoxFit.contain,
                ),
              ),
              SizedBox(width: cardWidth * 0.06),
              // Text column with flexible width
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      type,
                      style: TextStyle(
                        fontSize: cardHeight * 0.2,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey[800],
                        letterSpacing: 0.5,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      '$quantity unit',
                      style: TextStyle(
                        fontSize: cardHeight * 0.16,
                        color: borderColor ?? IColors.black,
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
