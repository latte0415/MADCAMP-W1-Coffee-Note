import 'package:flutter/material.dart';
import '../../../../models/note.dart';
import '../../../../models/detail.dart';
import '../../../../shared/presentation/modals/details_modal.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_spacing.dart';
import '../../../../theme/app_text_styles.dart';
import '../../../../theme/app_component_styles.dart';

Widget sortButton(
    BuildContext context,
    String label,
    dynamic option,
    dynamic currentSort,
    double scale,
    VoidCallback onTap
    ) {
  // 기존 로직 유지: runtimeType 비교
  bool isSelected = (currentSort.runtimeType == option.runtimeType);

  return GestureDetector(
    onTap: onTap,
    child: Container(
      padding: EdgeInsets.symmetric(horizontal: 30 * scale, vertical: 15 * scale),
      decoration: BoxDecoration(
        color: isSelected ? AppColors.primaryDark : Colors.grey[400],
        borderRadius: BorderRadius.circular(AppSpacing.borderRadiusLarge * scale),
      ),
      child: Text(
        label,
        style: AppTextStyles.bodyTextWhite.copyWith(fontSize: 30 * scale),
      ),
    ),
  );
}

/// 빈 가이드 카드
Widget buildEmptyGuideCard(double scale) {
  return Card(
    margin: EdgeInsets.symmetric(vertical: 20 * scale),
    elevation: 0,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppSpacing.borderRadiusSmall * scale),
      side: BorderSide(
        color: AppColors.border,
        width: AppSpacing.borderWidth * scale,
      ),
    ),
    child: Container(
      padding: EdgeInsets.all(40 * scale),
      child: Column(
        children: [
          Icon(Icons.coffee_outlined, size: 60 * scale, color: AppColors.border),
          SizedBox(height: 20 * scale),
          Text(
            "아직 작성된 노트가 없어요",
            style: AppTextStyles.bodyText.copyWith(
              fontSize: 30 * scale,
              fontWeight: FontWeight.w700,
              color: AppColors.border,
            ),
          ),
          SizedBox(height: 15 * scale),
          Text(
            "하단의 + 버튼을 눌러\n첫 번째 커피 노트를 만들어보세요!",
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyText.copyWith(
              fontSize: 25 * scale,
              color: AppColors.border,
            ),
          ),
        ],
      ),
    ),
  );
}

/// 레벨 표시 (막대 그래프) - buildNoteCard에서 사용
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
      SizedBox(width: 10 * scale),
      Row(
        children: List.generate(starCount, (index) {
          return Container(
            width: 12 * scale,
            height: 28 * scale,
            margin: EdgeInsets.only(right: 6 * scale),
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

/// 상세 정보 텍스트 (Wrap)
Widget buildDetailInfo(Detail detail, double scale) {
  final infoList = <String>[];
  if (detail.originLocation != null && detail.originLocation!.isNotEmpty) infoList.add(detail.originLocation!);
  if (detail.variety != null && detail.variety!.isNotEmpty) infoList.add(detail.variety!);
  if (detail.process != null) infoList.add(detail.process!.displayName);
  if (detail.roastingPoint != null) infoList.add(detail.roastingPoint!.displayName);
  if (detail.method != null) infoList.add(detail.method!.displayName);

  return Wrap(
    spacing: 10 * scale,
    runSpacing: 10 * scale,
    children: infoList.map((info) => Text(
      info,
      style: AppTextStyles.bodyText.copyWith(fontSize: 30 * scale, fontWeight: FontWeight.w300, color: AppColors.primaryText),
    )).toList(),
  );
}

/// 노트 카드
Widget buildNoteCard(BuildContext context, Note note, double scale, VoidCallback onRefresh, Widget detailsModal) {
  return GestureDetector(
    onTap: () {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) => detailsModal,
      ).then((result) {
        if (result == true) {
          onRefresh();
        }
      });
    },
    child: Container(
      decoration: AppComponentStyles.noteCardDecoration.copyWith(
        borderRadius: BorderRadius.circular(AppSpacing.borderRadiusSmall * scale),
        border: Border.all(color: Colors.transparent, width: 0),
      ),
      child: FutureBuilder<Detail?>(
        future: (detailsModal as NoteDetailsModal).detailService.getDetailByNoteId(note.id),
        builder: (context, detailSnapshot) {
          final hasDetail = detailSnapshot.hasData && detailSnapshot.data != null;
          final detail = detailSnapshot.data;

          return Padding(
            padding: EdgeInsets.all(20 * scale),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // 1. 위치 정보
                          Row(
                            children: [
                              Icon(Icons.location_on, size: 24 * scale, color: AppColors.primaryText),
                              SizedBox(width: 8 * scale),
                              Text(
                                note.location,
                                style: AppTextStyles.bodyText.copyWith(
                                  fontSize: 30 * scale,
                                  fontWeight: FontWeight.w300,
                                  color: AppColors.primaryText,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(width: 24 * scale),
                          // 2. 날짜 정보
                          Row(
                            children: [
                              Icon(Icons.calendar_today, size: 24 * scale, color: AppColors.primaryText),
                              SizedBox(width: 8 * scale),
                              Text(
                                note.drankAt.toString().split(' ')[0],
                                style: AppTextStyles.bodyText.copyWith(
                                  fontSize: 30 * scale,
                                  fontWeight: FontWeight.w300,
                                  color: AppColors.primaryText,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(width: 24 * scale),
                          // 3. 별점 정보
                          Row(
                            children: [
                              Icon(Icons.star_rounded, size: 28 * scale, color: AppColors.primaryText), // 별 아이콘
                              SizedBox(width: 4 * scale),
                              Text(
                                '${note.score}', // 예: 4.5
                                style: AppTextStyles.bodyText.copyWith(
                                  fontSize: 30 * scale,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.primaryText,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      SizedBox(height: 20 * scale),
                      Text(
                        note.menu,
                        style: AppTextStyles.largeTitle.copyWith(fontSize: 40 * scale, color: AppColors.primaryDark),
                      ),
                      if (hasDetail && detail != null) ...[
                        SizedBox(height: 10 * scale),
                        buildDetailInfo(detail, scale),
                      ],
                      SizedBox(height: 17 * scale),
                      Text(
                        note.comment,
                        style: AppTextStyles.bodyText.copyWith(fontSize: 35 * scale, color: AppColors.primaryText),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 20 * scale),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      width: 220 * scale,
                      padding: EdgeInsets.symmetric(horizontal: 20 * scale, vertical: 20 * scale),
                      decoration: AppComponentStyles.filterAreaDecoration.copyWith(
                        borderRadius: BorderRadius.circular(AppSpacing.borderRadiusSmall * scale),
                        border: Border.all(color: AppColors.border, width: AppSpacing.borderWidth * scale),
                      ),
                      child: Column(
                        children: [
                          buildLevelDisplay("산미", note.levelAcidity, scale, AppColors.primaryDark),
                          SizedBox(height: 20 * scale),
                          buildLevelDisplay("바디", note.levelBody, scale, AppColors.primaryDark),
                          SizedBox(height: 20 * scale),
                          buildLevelDisplay("쓴맛", note.levelBitterness, scale, AppColors.primaryDark),
                        ],
                      ),
                    ),
                    if (hasDetail && detail != null && detail.tastingNotes != null && detail.tastingNotes!.isNotEmpty) ...[
                      SizedBox(height: 15 * scale),
                      SizedBox(
                        width: 220 * scale,
                        child: Wrap(
                          alignment: WrapAlignment.end,
                          spacing: 10 * scale,
                          runSpacing: 10 * scale,
                          children: detail.tastingNotes!.take(5).map((tag) => Container(
                            padding: EdgeInsets.symmetric(horizontal: 12 * scale, vertical: 6 * scale),
                            decoration: AppComponentStyles.hashtagDecoration.copyWith(
                              borderRadius: BorderRadius.circular(AppSpacing.borderRadiusLarge * scale),
                              color: AppColors.primaryDark,
                            ),
                            child: Text(
                                "#$tag",
                                style: AppComponentStyles.hashtagTextStyle.copyWith(fontSize: 24 * scale, color: Colors.white)
                            ),
                          )).toList(),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          );
        },
      ),
    ),
  );
}

/// 상세 필터 슬라이더
Widget buildFilterSlider(
  String label,
  double value,
  ValueChanged<double> onChanged,
  double scale, {
  ValueChanged<double>? onChangeEnd,
}) {
  return Row(
    children: [
      Container(
        width: 80 * scale,
        padding: const EdgeInsets.symmetric(vertical: 4),
        decoration: BoxDecoration(color: AppColors.primaryDark, borderRadius: BorderRadius.circular(15 * scale)),
        child: Center(
          child: Text(
            label,
            style: AppTextStyles.bodyText.copyWith(fontSize: 30 * scale, fontWeight: FontWeight.w700, color: Colors.white),
          ),
        ),
      ),
      Expanded(
        child: Slider(
          value: value,
          min: 1,
          max: 10,
          divisions: 9,
          activeColor: AppColors.primaryDark,
          inactiveColor: Colors.grey[300],
          onChanged: onChanged,
          onChangeEnd: onChangeEnd,
        ),
      ),
      SizedBox(
        width: 40 * scale,
        child: Text(
          "${value.toInt()}",
          textAlign: TextAlign.right,
          style: AppTextStyles.bodyText.copyWith(fontSize: 35 * scale, fontWeight: FontWeight.w700, color: AppColors.primaryDark),
        ),
      ),
    ],
  );
}
