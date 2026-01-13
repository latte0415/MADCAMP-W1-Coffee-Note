// lib/features/ai_guide/presentation/pages/ai_guide_page.dart
import 'package:flutter/material.dart';
import '../../../../theme/theme.dart';
import '../../../../models/enums/process_type.dart';
import '../../../../models/enums/roasting_point_type.dart';
import '../../../../models/enums/method_type.dart';
import '../../../../shared/presentation/modals/creation_modal.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../backend/providers.dart';

class AiGuidePage extends ConsumerStatefulWidget {
  const AiGuidePage({super.key});

  @override
  ConsumerState<AiGuidePage> createState() => _AiGuidePageState();
}

class _AiGuidePageState extends ConsumerState<AiGuidePage> {
  final TextEditingController _inputController = TextEditingController();
  bool _isLoading = false;
  bool _hasResult = false;
  
  // AI 생성 결과
  Map<String, dynamic>? _mappingResult;
  String _sensoryGuide = '';
  String _inputText = '';

  @override
  void dispose() {
    _inputController.dispose();
    super.dispose();
  }

  Future<void> _handleGetGuide() async {
    final inputText = _inputController.text.trim();
    if (inputText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('입력을 입력해주세요.')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _hasResult = false;
      _inputText = inputText;
    });

    try {
      final apiService = ref.read(apiServiceProvider);
      final result = await apiService.chatForSensoryGuide(inputText);
      setState(() {
        _mappingResult = result['mappingResult'] as Map<String, dynamic>?;
        _sensoryGuide = result['sensoryGuide'] as String? ?? '';
        _hasResult = true;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('오류가 발생했습니다: $e')),
        );
      }
    }
  }

  void _handleContinueRecording() {
    if (_mappingResult == null) return;
    
    showDialog(
      context: context,
      builder: (context) => NoteCreatePopup(
        prefillData: _mappingResult,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scaleFactor = MediaQuery.of(context).size.width / AppSpacing.designWidth;
    final scaledPadding = AppSpacing.horizontalPadding * scaleFactor.clamp(0.3, 1.2);
    final scale = scaleFactor.clamp(0.3, 1.2);

    return Scaffold(
      body: Column(
        children: [
          // --- [고정 상단 영역] ---
          Padding(
            padding: EdgeInsets.fromLTRB(scaledPadding, 30 * scale, scaledPadding, 10 * scale),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // title
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center, // 아이콘과 글자 높이 맞춤
                  children: [
                    Icon(
                      Icons.auto_awesome,
                      size: 45 * scale, // 텍스트 폰트 사이즈와 맞춤 [cite: 1-1-0]
                      color: Colors.black, // AI 느낌이 나도록 금색/노란색 계열 추천
                    ),
                    SizedBox(width: 15 * scale), // 아이콘과 글자 사이 간격
                    Text(
                      '커피에 대한 정보를 입력해주세요',
                      style: AppTextStyles.bodyText.copyWith(
                        fontSize: 45 * scale,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20 * scale),
                // 검색창
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 1),
                  child: TextField(
                    controller: _inputController,
                    style: AppTextStyles.bodyText.copyWith(
                      fontSize: 35 * scale,
                      fontWeight: FontWeight.w700,
                    ),
                    decoration: AppComponentStyles.textInputDecoration(hintText: "예: 에티오피아 예가체프 워시드 중배전").copyWith(
                      hintStyle: TextStyle(color: AppColors.primaryText.withOpacity(0.3)),
                      contentPadding: const EdgeInsets.fromLTRB(0, 4, 0, 4),
                      // 하단 밑줄 스타일
                      border: const UnderlineInputBorder(
                        borderSide: BorderSide(color: AppColors.border, width: 1),
                      ),
                      enabledBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(color: AppColors.border, width: 1),
                      ),
                      focusedBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(color: AppColors.border, width: 1),
                      ),
                    ),
                    onChanged: (value) => setState(() => _hasResult = false),
                  ),
                ),
                SizedBox(height: 15 * scale),
                Text(
                  '* 국가, 품종, 로스팅, 가공 방식 등을 자세히 입력할수록 \n 더 정확한 테이스팅 노트를 추측할 수 있습니다.',
                  style: TextStyle(fontSize: 30 * scale, color: const Color(0xFF666666)),
                ),
                SizedBox(height: 30 * scale),
                // 가이드 받기 버튼
                Center(
                  child: SizedBox(
                    width: 352 * scale,
                    height: 91 * scale,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _handleGetGuide,
                      style: AppComponentStyles.primaryButton.copyWith(
                        shape: MaterialStateProperty.all(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(85 * scale),
                          ),
                        ),
                        padding: MaterialStateProperty.all(EdgeInsets.zero),
                      ),
                      child: Text(
                        _isLoading ? '생성 중...' : '가이드 받기',
                        style: AppTextStyles.bodyTextWhite.copyWith(
                          fontSize: 35 * scale,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 30 * scale),
          // --- [스크롤 영역] ---
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: scaledPadding),
              child: Container(
                width: double.infinity,
                // 결과 표시 영역의 최대 높이
                constraints: BoxConstraints(
                  minHeight: MediaQuery.of(context).size.height * 0.5,
                ),
                alignment: Alignment.center,
                margin: EdgeInsets.only(bottom: 20 * scale), // 하단 여백 추가
                padding: EdgeInsets.all(25 * scale),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  border: Border.all(color: AppColors.border, width: 1),
                  borderRadius: BorderRadius.circular(30 * scale),
                ),
                child: _hasResult && _mappingResult != null
                    ? _buildResultContent(scale)
                    : _buildEmptyContent(scale),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyContent(double scale) {
    return Text(
      '입력하신 내용을 바탕으로 \n AI가 커피를 즐길 수 있게 도와줍니다 :)',
      style: AppTextStyles.bodyText.copyWith(
        fontSize: 40 * scale,
        fontWeight: FontWeight.w700,
        color: AppColors.primaryText.withOpacity(0.27),
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildResultContent(double scale) {
    final result = _mappingResult!;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 상단 입력 텍스트 표시
        // if (_inputText.isNotEmpty)
        //   Padding(
        //     padding: EdgeInsets.only(bottom: 20 * scale),
        //     child: Text(
        //       _inputText,
        //       style: AppTextStyles.bodyText.copyWith(
        //         fontSize: 40 * scale,
        //         fontWeight: FontWeight.w700,
        //       ),
        //     ),
        //   ),
        
        // 국가/지역
        _buildInfoRow('국가/지역', result['originLocation'] as String?, scale),
        SizedBox(height: 20 * scale),
        
        // 품종
        _buildInfoRow('품종', result['variety'] as String?, scale),
        SizedBox(height: 20 * scale),
        
        // 가공 방식
        _buildInfoRowWithDropdown(
          '가공 방식',
          result['process'] as ProcessType?,
          result['processText'] as String?,
          ProcessType.values,
          scale,
        ),
        SizedBox(height: 20 * scale),
        
        // 로스팅 포인트
        _buildInfoRowWithDropdown(
          '로스팅 포인트',
          result['roastingPoint'] as RoastingPointType?,
          result['roastingPointText'] as String?,
          RoastingPointType.values,
          scale,
        ),
        SizedBox(height: 20 * scale),
        
        // 추출 방식
        _buildInfoRowWithDropdown(
          '추출 방식',
          result['method'] as MethodType?,
          result['methodText'] as String?,
          MethodType.values,
          scale,
        ),
        SizedBox(height: 30 * scale),
        
        // 테이스팅 노트
        _buildTastingNotes(result['tastingNotes'] as List<String>?, scale),
        SizedBox(height: 30 * scale),
        
        // 센서리 가이드
        _buildSensoryGuide(scale),
        SizedBox(height: 30 * scale),

        // 이어서 기록하기 버튼
        Align(
          alignment: Alignment.centerRight,
          child: SizedBox(
            width: 352 * scale,
            height: 91 * scale,
            child: ElevatedButton(
              onPressed: _handleContinueRecording,
              style: AppComponentStyles.primaryButton.copyWith(
                shape: MaterialStateProperty.all(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(85 * scale),
                  ),
                ),
                padding: MaterialStateProperty.all(EdgeInsets.zero),
              ),
              child: Text(
                '이어서 기록하기',
                style: AppTextStyles.bodyTextWhite.copyWith(
                  fontSize: 35 * scale,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String? value, double scale) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.bodyText.copyWith(
            fontSize: 30 * scale,
            fontWeight: FontWeight.w700,
          ),
        ),
        SizedBox(height: 20 * scale),
        Text(
          value ?? '알 수 없음',
          style: AppTextStyles.bodyText.copyWith(
            fontSize: 35 * scale,
            fontWeight: FontWeight.w700,
            color: value != null ? Colors.black : AppColors.primaryText.withOpacity(0.27),
          ),
        ),
        SizedBox(height: 20 * scale),
        const Divider(
            height: 1,
            thickness: 0.5, // buildField와 동일한 0.5 두께
            color: AppColors.border
        ),
        SizedBox(height: 20 * scale), // 다음 항목과의 여백
      ],
    );
  }

  Widget _buildInfoRowWithDropdown<T>(
    String label,
    T? enumValue,
    String? textValue,
    List<T> allValues,
    double scale,
  ) {
    String displayText = '알 수 없음';
    Color textColor = AppColors.primaryText.withOpacity(0.27);

    if (enumValue != null) {
      if (enumValue is ProcessType) {
        displayText = enumValue.displayName;
      } else if (enumValue is RoastingPointType) {
        displayText = enumValue.displayName;
      } else if (enumValue is MethodType) {
        displayText = enumValue.displayName;
      }
      textColor = Colors.black;
    } else if (textValue != null && textValue.isNotEmpty) {
      displayText = textValue;
      textColor = Colors.black;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 가공 방식, 로스팅 포인트, 추출 방식 title
                  Text(
                    label,
                    style: AppTextStyles.bodyText.copyWith(
                      fontSize: 30 * scale,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: 20 * scale),
                  // 각 label의 검색값
                  Text(
                    displayText,
                    style: AppTextStyles.bodyText.copyWith(
                      fontSize: 35 * scale,
                      fontWeight: FontWeight.w700,
                      color: textColor,
                    ),
                  ),
                  SizedBox(height: 20 * scale),
                  const Divider(
                      height: 1,
                      thickness: 0.5,
                      color: AppColors.border
                  ),
                  SizedBox(height: 20 * scale),
                ],
              ),
            ),
            SizedBox(width: 20 * scale),
            // 드롭다운 (읽기 전용)
            Container(
              width: 250 * scale,
              height: 62 * scale,
              decoration: BoxDecoration(
                color: const Color(0xFFE7E7E7),
                borderRadius: BorderRadius.circular(10 * scale),
              ),
              padding: EdgeInsets.symmetric(horizontal: 20 * scale),
              child: DropdownButton<T>(
                value: enumValue,
                items: allValues.map((item) {
                  String text = '';
                  if (item is ProcessType) {
                    text = item.displayName;
                  } else if (item is RoastingPointType) {
                    text = item.displayName;
                  } else if (item is MethodType) {
                    text = item.displayName;
                  }
                  return DropdownMenuItem(
                    value: item,
                    child: Text(
                      text,
                      style: AppTextStyles.bodyText.copyWith(
                        fontSize: 30 * scale,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF4E4E4E),
                      ),
                    ),
                  );
                }).toList(),
                onChanged: null, // 읽기 전용
                isExpanded: true,
                underline: const SizedBox(),
                icon: Icon(
                  Icons.arrow_drop_down,
                  color: const Color(0xFF676767),
                  size: 24 * scale,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTastingNotes(List<String>? notes, double scale) {
    if (notes == null || notes.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '테이스팅 노트',
            style: AppTextStyles.bodyText.copyWith(
              fontSize: 30 * scale,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 20 * scale),
          Text(
            "알 수 없음",
            style: AppTextStyles.bodyText.copyWith(
              fontSize: 35 * scale,
              fontWeight: FontWeight.w700,
              color: AppColors.primaryText.withOpacity(0.27),
            ),
          ),
          SizedBox(height: 20 * scale),
          const Divider(height: 1, thickness: 0.5, color: AppColors.border), // 밑줄 양식 통일
          SizedBox(height: 20 * scale),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '테이스팅 노트',
          style: AppTextStyles.bodyText.copyWith(
            fontSize: 30 * scale,
            fontWeight: FontWeight.w700,
          ),
        ),
        SizedBox(height: 20 * scale),
        Wrap(
          spacing: 16 * scale,
          runSpacing: 10 * scale,
          children: notes.map((note) {
            return Container(
              padding: EdgeInsets.symmetric(
                horizontal: 20 * scale,
                vertical: 10 * scale,
              ),
              decoration: BoxDecoration(
                color: AppColors.primaryDark,
                borderRadius: BorderRadius.circular(20 * scale),
              ),
              child: Text(
                '#$note',
                style: AppTextStyles.bodyTextWhite.copyWith(
                  fontSize: 30 * scale,
                ),
              ),
            );
          }).toList(),
        ),
        SizedBox(height: 20 * scale),
        const Divider(
            height: 1,
            thickness: 0.5, // buildField와 동일한 0.5 두께
            color: AppColors.border
        ),
        SizedBox(height: 20 * scale), // 다음 항목과의 여백
      ],
    );
  }

  Widget _buildSensoryGuide(double scale) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '센서리 가이드',
          style: AppTextStyles.bodyText.copyWith(
            fontSize: 35 * scale,
            fontWeight: FontWeight.w700,
          ),
        ),
        SizedBox(height: 20 * scale),
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(30 * scale),
          decoration: BoxDecoration(
            color: const Color(0xFFF1F1F1),
            borderRadius: BorderRadius.circular(20 * scale),
          ),
          child: Text(
            _sensoryGuide.isNotEmpty
                ? _sensoryGuide
                : '센서리 가이드를 불러오는 중...',
            style: AppTextStyles.bodyText.copyWith(
              fontSize: 30 * scale,
              color: Colors.black,
            ),
          ),
        ),
      ],
    );
  }
}
