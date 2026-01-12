// lib/pages/ai_guide_page.dart
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';
import '../theme/app_component_styles.dart';
import '../services/api_service.dart';
import '../models/enums/process_type.dart';
import '../models/enums/roasting_point_type.dart';
import '../models/enums/method_type.dart';

class AiGuidePage extends StatefulWidget {
  const AiGuidePage({super.key});

  @override
  State<AiGuidePage> createState() => _AiGuidePageState();
}

class _AiGuidePageState extends State<AiGuidePage> {
  final TextEditingController _inputController = TextEditingController();
  String _outputText = '';
  bool _isLoading = false;

  @override
  void dispose() {
    _inputController.dispose();
    super.dispose();
  }

  Future<void> _handleExecute() async {
    final inputText = _inputController.text.trim();
    if (inputText.isEmpty) {
      setState(() {
        _outputText = '입력을 입력해주세요.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _outputText = '처리 중...';
    });

    try {
      final result = await APIService.instance.chatForMapping(inputText);
      final formattedResult = _formatMappingResult(result);
      setState(() {
        _outputText = formattedResult;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _outputText = '오류가 발생했습니다: $e';
        _isLoading = false;
      });
    }
  }

  String _formatMappingResult(Map<String, dynamic> result) {
    final buffer = StringBuffer();
    
    if (result['originLocation'] != null) {
      buffer.writeln('원산지: ${result['originLocation']}');
    }
    
    if (result['variety'] != null) {
      buffer.writeln('품종: ${result['variety']}');
    }
    
    if (result['process'] != null) {
      final process = result['process'];
      if (process is ProcessType) {
        buffer.write('처리 방식: ${process.displayName}');
        if (result['processText'] != null) {
          buffer.write(' (${result['processText']})');
        }
        buffer.writeln();
      }
    }
    
    if (result['roastingPoint'] != null) {
      final roastingPoint = result['roastingPoint'];
      if (roastingPoint is RoastingPointType) {
        buffer.write('로스팅 포인트: ${roastingPoint.displayName}');
        if (result['roastingPointText'] != null) {
          buffer.write(' (${result['roastingPointText']})');
        }
        buffer.writeln();
      }
    }
    
    if (result['method'] != null) {
      final method = result['method'];
      if (method is MethodType) {
        buffer.write('추출 방식: ${method.displayName}');
        if (result['methodText'] != null) {
          buffer.write(' (${result['methodText']})');
        }
        buffer.writeln();
      }
    }
    
    final tastingNotes = result['tastingNotes'] as List<String>?;
    if (tastingNotes != null && tastingNotes.isNotEmpty) {
      buffer.writeln('테이스팅 노트: ${tastingNotes.join(', ')}');
    }
    
    if (buffer.isEmpty) {
      return '추출된 정보가 없습니다.';
    }
    
    return buffer.toString();
  }

  @override
  Widget build(BuildContext context) {
    final scaleFactor = MediaQuery.of(context).size.width / AppSpacing.designWidth;
    final scaledPadding = AppSpacing.horizontalPadding * scaleFactor.clamp(0.3, 1.2);

    return Scaffold(
      appBar: AppBar(
        title: const Text('AI 가이드'),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: scaledPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(height: 30 * scaleFactor.clamp(0.3, 1.2)),
            // 입력 영역
            Expanded(
              flex: 1,
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: AppColors.border,
                    width: AppSpacing.borderWidth,
                  ),
                  borderRadius: BorderRadius.circular(AppSpacing.borderRadiusSmall),
                ),
                padding: EdgeInsets.all(20 * scaleFactor.clamp(0.3, 1.2)),
                child: TextField(
                  controller: _inputController,
                  maxLines: null,
                  expands: true,
                  textAlignVertical: TextAlignVertical.top,
                  style: AppTextStyles.bodyText.copyWith(
                    fontSize: 30 * scaleFactor.clamp(0.3, 1.2),
                  ),
                  decoration: const InputDecoration(
                    hintText: '입력하세요...',
                    border: InputBorder.none,
                    hintStyle: TextStyle(color: AppColors.border),
                  ),
                ),
              ),
            ),
            SizedBox(height: 30 * scaleFactor.clamp(0.3, 1.2)),
            // 실행 버튼
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _handleExecute,
                style: AppComponentStyles.primaryButton.copyWith(
                  padding: MaterialStateProperty.all(
                    EdgeInsets.symmetric(
                      horizontal: 40 * scaleFactor.clamp(0.3, 1.2),
                      vertical: 20 * scaleFactor.clamp(0.3, 1.2),
                    ),
                  ),
                ),
                child: Text(
                  _isLoading ? '처리 중...' : '실행',
                  style: AppTextStyles.bodyTextWhite.copyWith(
                    fontSize: 30 * scaleFactor.clamp(0.3, 1.2),
                  ),
                ),
              ),
            ),
            SizedBox(height: 30 * scaleFactor.clamp(0.3, 1.2)),
            // 출력 영역
            Expanded(
              flex: 1,
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: AppColors.border,
                    width: AppSpacing.borderWidth,
                  ),
                  borderRadius: BorderRadius.circular(AppSpacing.borderRadiusSmall),
                  color: AppColors.background,
                ),
                padding: EdgeInsets.all(20 * scaleFactor.clamp(0.3, 1.2)),
                child: SingleChildScrollView(
                  child: Text(
                    _outputText.isEmpty ? '출력 결과가 여기에 표시됩니다...' : _outputText,
                    style: AppTextStyles.bodyText.copyWith(
                      fontSize: 30 * scaleFactor.clamp(0.3, 1.2),
                      color: _outputText.isEmpty ? AppColors.border : AppColors.primaryText,
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 30 * scaleFactor.clamp(0.3, 1.2)),
          ],
        ),
      ),
    );
  }
}