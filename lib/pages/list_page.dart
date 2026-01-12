import 'dart:math';
import 'package:flutter/material.dart';
import '../../models/note.dart';
import '../../models/sort_option.dart';
import '../../services/note_service.dart';
import 'modals/details_modal.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_text_styles.dart';
import '../../theme/app_component_styles.dart';
import '../../widget/list_widget.dart';

class ListPage extends StatefulWidget {
  const ListPage({super.key});

  @override
  State<ListPage> createState() => ListPageState();
}

class ListPageState extends State<ListPage> {

  // 외부(MainPage)에서 이 함수를 부르면 리스트가 새로고침됩니다.
  void refreshNotes() {
    setState(() {
      // FutureBuilder가 _getSortedNotes()를 다시 호출하게 유도합니다.
    });
  }

  // 현재 선택된 정렬 옵션 상태 (기본값: 날짜 최신순)
  SortOption _currentSort = const DateSortOption(ascending: false);

  // 검색어 상태
  String? _searchQuery;

  // 상세 필터 상태
  bool _showDetailFilter = false;
  int? _filterAcidity;
  int? _filterBody;
  int? _filterBitterness;

  // 스케일 팩터 계산
  double _getScaleFactor(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final scaleFactor = screenWidth / AppSpacing.designWidth;
    // 최소/최대 스케일 팩터 제한 (0.3 ~ 1.2)
    return scaleFactor.clamp(0.3, 1.2);
  }

  // 데이터를 가져와서 검색, 필터, 정렬을 적용하는 함수
  Future<List<Note>> _getSortedNotes() async {
    List<Note> notes;

    // 1. 검색어가 있으면 검색 결과 사용, 없으면 전체 노트 사용
    if (_searchQuery != null && _searchQuery!.isNotEmpty) {
      notes = await NoteService.instance.searchNotes(_searchQuery!, _currentSort);
    } else {
      notes = await NoteService.instance.getAllNotes(_currentSort);
    }

    // 2. 상세 필터가 활성화되어 있고 값이 모두 설정되어 있으면 유사도 필터 적용
    if (_showDetailFilter &&
        _filterAcidity != null &&
        _filterBody != null &&
        _filterBitterness != null) {
      notes = await _applySimilarityFilter(
          notes,
          _filterAcidity!,
          _filterBody!,
          _filterBitterness!
      );
    }

    // 3. 정렬 옵션 적용
    if (_currentSort is DateSortOption) {
      notes.sort((a, b) => _currentSort.ascending
          ? a.drankAt.compareTo(b.drankAt)
          : b.drankAt.compareTo(a.drankAt));
    } else if (_currentSort is ScoreSortOption) {
      notes.sort((a, b) => _currentSort.ascending
          ? a.score.compareTo(b.score)
          : b.score.compareTo(a.score));
    }
    return notes;
  }

  // 유사도 필터 적용 함수
  Future<List<Note>> _applySimilarityFilter(
      List<Note> notes,
      int acidity,
      int body,
      int bitterness,
      ) async {
    if (notes.isEmpty) return notes;

    // 입력받은 notes에 대해 유사도 계산
    final notesWithSimilarity = notes.map((note) {
      final similarity = _calculateSimilarity(note, acidity, body, bitterness);
      return (note: note, similarity: similarity);
    }).toList();

    // 유사도 순으로 정렬
    notesWithSimilarity.sort((a, b) => b.similarity.compareTo(a.similarity));

    // 노트만 반환 (유사도 순)
    return notesWithSimilarity.map((item) => item.note).toList();
  }

  // 유사도 계산 함수 (NoteService의 _calculateSimilarity 로직 재사용)
  double _calculateSimilarity(Note note, int acidity, int body, int bitterness) {
    final diffAcidity = pow(note.levelAcidity - acidity, 2).toDouble();
    final diffBody = pow(note.levelBody - body, 2).toDouble();
    final diffBitterness = pow(note.levelBitterness - bitterness, 2).toDouble();

    final diff = sqrt(diffAcidity + diffBody + diffBitterness);

    // 각 값이 1-10 범위이므로 최대 차이는 9지만 10으로 가정
    final maxDiff = sqrt(300.0);

    // 유사도: 1.0 (완전 일치) ~ 0.0 (완전 불일치)
    final similarity = 1.0 - (diff / maxDiff);

    // 음수 방지 (이론적으로는 발생하지 않지만 안전장치)
    return similarity.clamp(0.0, 1.0);
  }
  @override
  Widget build(BuildContext context) {
    final scale = _getScaleFactor(context);

    return Column(
      children: [
        // 검색창
        Padding(
          padding: EdgeInsets.fromLTRB(16 * scale, 20 * scale, 16 * scale, 10 * scale),
          child: TextField(
            style: AppTextStyles.bodyText.copyWith(fontSize: 30 * scale),
            decoration: AppComponentStyles.textInputDecoration(
              hintText: "검색어를 입력하세요.",
            ).copyWith(
              hintStyle: AppTextStyles.bodyText.copyWith(
                fontSize: 25 * scale,
                color: AppColors.primaryText.withOpacity(0.5),
              ),
            ),
            onChanged: (value) {
              setState(() {
                _searchQuery = value.isEmpty ? null : value;
              });
            },
          ),
        ),

        // ✅ [수정됨] 상세 필터 전체를 감싸는 연회색 컨테이너 추가
        Container(
          margin: EdgeInsets.symmetric(
            horizontal: AppSpacing.horizontalPadding * scale,
            vertical: 10 * scale,
          ),
          decoration: BoxDecoration(
            color: Colors.grey[100], // 연회색 배경 적용 [cite: 1-1-0]
            borderRadius: BorderRadius.circular(AppSpacing.borderRadiusSmall * scale),
          ),
          child: Column(
            children: [
              // 상세 필터 토글 버튼 영역
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: 16 * scale,
                  vertical: 8 * scale,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton.icon(
                      onPressed: () {
                        setState(() {
                          _showDetailFilter = !_showDetailFilter;
                          if (!_showDetailFilter) {
                            _filterAcidity = null;
                            _filterBody = null;
                            _filterBitterness = null;
                          }
                        });
                      },
                      icon: Icon(
                        _showDetailFilter ? Icons.expand_less : Icons.expand_more,
                        color: AppColors.primaryDark,
                        size: 30 * scale,
                      ),
                      label: Text(
                        "상세필터",
                        style: AppTextStyles.bodyText.copyWith(fontSize: 30 * scale),
                      ),
                    ),
                    if (_showDetailFilter &&
                        _filterAcidity != null &&
                        _filterBody != null &&
                        _filterBitterness != null)
                      TextButton(
                        onPressed: () {
                          setState(() {
                            _filterAcidity = null;
                            _filterBody = null;
                            _filterBitterness = null;
                          });
                        },
                        child: Text(
                          "초기화",
                          style: AppTextStyles.bodyText.copyWith(fontSize: 30 * scale),
                        ),
                      ),
                  ],
                ),
              ),

              // 상세 필터 슬라이더 (spread 상태)
              if (_showDetailFilter) ...[
                Padding(
                  padding: EdgeInsets.fromLTRB(20 * scale, 0, 20 * scale, 20 * scale),
                  child: Container(
                    decoration: AppComponentStyles.filterAreaDecoration.copyWith(
                      borderRadius: BorderRadius.circular(AppSpacing.borderRadiusSmall * scale),
                      border: Border.all(color: Colors.transparent, width: 0),
                      // 필요 시 배경색을 부모와 맞춤
                      color: Colors.transparent,
                    ),
                    padding: EdgeInsets.all(20 * scale),
                    child: Column(
                      children: [
                        buildFilterSlider(
                          '산미',
                          (_filterAcidity ?? 5).toDouble(),
                              (value) => setState(() => _filterAcidity = value.toInt()),
                          scale,
                        ),
                        // SizedBox(height: 5 * scale),
                        buildFilterSlider(
                          '바디',
                          (_filterBody ?? 5).toDouble(),
                              (value) => setState(() => _filterBody = value.toInt()),
                          scale,
                        ),
                        // SizedBox(height: 5 * scale),
                        buildFilterSlider(
                          '쓴맛',
                          (_filterBitterness ?? 5).toDouble(),
                              (value) => setState(() => _filterBitterness = value.toInt()),
                          scale,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),

        // 정렬 버튼
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: AppSpacing.horizontalPadding * scale,
            vertical: 10 * scale,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              sortButton(
                context,
                "최신순",
                const DateSortOption(ascending: false),
                _currentSort,
                scale,
                    () => setState(() => _currentSort = const DateSortOption(ascending: false)),
              ),
              SizedBox(width: 20 * scale),
              sortButton(
                context,
                "별점순",
                const ScoreSortOption(ascending: false),
                _currentSort,
                scale,
                    () => setState(() => _currentSort = const ScoreSortOption(ascending: false)),
              ),
            ],
          ),
        ),

        // FutureBuilder 영역
        Expanded(
          child: FutureBuilder<List<Note>>(
            future: _getSortedNotes(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return Center(child: Text('에러 발생: ${snapshot.error}'));
              }

              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return ListView(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppSpacing.horizontalPadding * scale,
                  ),
                  children: [
                    buildEmptyGuideCard(scale),
                  ],
                );
              }

              final notes = snapshot.data!;
              return ListView.builder(
                padding: EdgeInsets.symmetric(
                  horizontal: AppSpacing.horizontalPadding * scale,
                  vertical: 20 * scale,
                ),
                itemCount: notes.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: EdgeInsets.only(bottom: 30 * scale),
                    child: buildNoteCard(
                      context,
                      notes[index],
                      scale,
                          () => setState(() {}), // refreshNotes를 대신하는 상태 갱신 콜백 [cite: 1-1-0]
                      NoteDetailsModal(note: notes[index]), // 모달 위젯 직접 주입
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }


}
