import 'package:flutter/material.dart';
import '../../../../theme/app_text_styles.dart';

/// 레벨 표시 (막대 그래프)
Widget buildLevelDisplay(String label, int value, double scale, Color color) {
  final starCount = (value / 2).ceil();
  return Row(
    mainAxisAlignment: MainAxisAlignment.start,
    crossAxisAlignment: CrossAxisAlignment.center,
    children: [
      Flexible(
        flex: 2,
        child: Text(
            label,
            style: AppTextStyles.bodyText.copyWith(
                fontSize: 25 * scale,
                color: color
            ),
            overflow: TextOverflow.ellipsis
        ),
      ),
      SizedBox(width: 13 * scale),
      Row(
        children: List.generate(starCount, (index) {
          return Container(
            width: 10 * scale,
            height: 24 * scale,
            margin: EdgeInsets.only(right: 5 * scale),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(2 * scale),
            ),
          );
        }),
      ),
    ],
  );
}
