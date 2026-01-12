import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../theme/app_component_styles.dart';
import '../../models/enums/process_type.dart';
import '../../models/enums/roasting_point_type.dart';
import '../../models/enums/method_type.dart';

Widget buildField(String label, TextEditingController controller, bool isEditing, {ValueChanged<String>? onChanged}) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 1),
    child: TextField(
      onChanged: onChanged,
      controller: controller,
      readOnly: !isEditing,
      style: AppTextStyles.bodyText.copyWith(fontSize: 14),
      decoration: AppComponentStyles.textInputDecoration(hintText: "").copyWith(
        labelText: label,
        labelStyle: const TextStyle(fontSize: 16, color: AppColors.primaryText, fontWeight: FontWeight.bold),
        floatingLabelBehavior: FloatingLabelBehavior.always,
        contentPadding: const EdgeInsets.fromLTRB(0, 4, 0, 4),

        // 하단 밑줄 스타일
        border: const UnderlineInputBorder(
          borderSide: BorderSide(color: AppColors.border, width: 0.5),
        ),
        enabledBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: AppColors.border, width: 0.5),
        ),
        focusedBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: AppColors.border, width:0.5),
        ),
      ),
    ),
  );
}

Widget buildSlider(BuildContext context, String label, double value, ValueChanged<double> onChanged, bool isEditing) {
  return Padding(
    padding: EdgeInsets.symmetric(vertical: 4),
    child: Row( //Column에서 Row로 변경하여 라벨과 슬라이더를 한 줄에 배치
      children: [
        //라벨 영역: 고정 너비를 주어 여러 슬라이더의 시작점을 맞춤
        SizedBox(
          width: 50,
          child: Text(
            label,
            style: AppTextStyles.bodyText.copyWith(fontSize: 16),
          ),
        ),

        // 슬라이더 영역: Expanded를 사용하여 Row 내 남은 공간을 가득 채움
        Expanded(
          child: SliderTheme(
            data: SliderTheme.of(context).copyWith(
              trackHeight: 2,
              thumbShape: RoundSliderThumbShape(enabledThumbRadius: 6),
              overlayShape: RoundSliderOverlayShape(overlayRadius: 12),
            ),
            child: Slider(
              value: value,
              min: 1,
              max: 10,
              divisions: 9,
              activeColor: AppColors.primaryDark,
              inactiveColor: AppColors.border,
              onChanged: isEditing ? onChanged : null,
            ),
          ),
        ),

        // ✅ [수정됨] 수치 표시 영역: 슬라이더 우측에 현재 값을 숫자로 표시
        SizedBox(
          width: 30,
          child: Text(
            "${value.toInt()}",
            textAlign: TextAlign.right,
            style: AppTextStyles.bodyText.copyWith(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryDark,
            ),
          ),
        ),
      ],
    ),
  );
}

Widget buildDropdown<T>(String label, T value, List<T> items, ValueChanged<T?> onChanged) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryText
          ),
        ),
        const SizedBox(height: 2), // 제목과 드롭다운 사이 간격
        DropdownButtonFormField<T>(
          value: value,
          style: AppTextStyles.bodyText.copyWith(fontSize: 15, color: AppColors.primaryDark),
          icon: const Icon(Icons.arrow_drop_down, color: AppColors.primaryDark, size: 20),
          decoration: const InputDecoration(
            isDense: true,
            contentPadding: EdgeInsets.symmetric(vertical: 4),
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
          ),
          items: items.map((item) {
            String text = "";
            if (item is ProcessType) { text = item.displayName; }
            else if (item is RoastingPointType) { text = item.displayName; }
            else if (item is MethodType) { text = item.displayName; }
            return DropdownMenuItem(
              value: item,
              child: Text(text, style: const TextStyle(fontSize: 15)),
            );
          }).toList(),
          onChanged: onChanged,
        ),
        // 다른 필드들과 동일한 하단 밑줄 추가 [cite: 1-1-0]
        const Divider(height: 1, thickness: 0.5, color: AppColors.border),
      ],
    ),
  );
}

Widget buildReadOnlyDetail(String label, String value) {
  return Padding(
    // ✅ _buildField와 동일하게 외부 간격 조정 [cite: 1-1-0]
    padding: const EdgeInsets.symmetric(vertical: 2),
    child: TextField(
      // ✅ 읽기 전용으로 설정하여 텍스트 선택은 가능하지만 수정은 불가능하게 함 [cite: 1-1-0]
      controller: TextEditingController(text: value),
      readOnly: true,
      style: AppTextStyles.bodyText.copyWith(fontSize: 15, color: AppColors.primaryDark),
      decoration: AppComponentStyles.textInputDecoration(hintText: label).copyWith(
        labelText: label,
        // ✅ [수정됨] 제목(라벨) 스타일 통일 [cite: 1-1-0]
        labelStyle: const TextStyle(fontSize: 12, color: AppColors.primaryText, fontWeight: FontWeight.bold),
        floatingLabelBehavior: FloatingLabelBehavior.always,
        isDense: true,
        // ✅ [수정됨] 텍스트와 밑줄 사이 간격 통일 [cite: 1-1-0]
        contentPadding: const EdgeInsets.fromLTRB(0, 4, 0, 4),

        // ✅ [수정됨] 입력 필드와 동일한 하단 밑줄 적용 [cite: 1-1-0]
        border: const UnderlineInputBorder(
          borderSide: BorderSide(color: AppColors.border, width: 0.5),
        ),
        enabledBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: AppColors.border, width: 0.5),
        ),
        // 조회 모드이므로 포커스 스타일은 따로 주지 않거나 기본 스타일 유지
        focusedBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: AppColors.border, width: 0.5),
        ),
      ),
    ),
  );
}