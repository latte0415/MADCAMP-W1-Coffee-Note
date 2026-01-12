import 'dart:math';
import 'package:flutter/material.dart';
import '../../models/note.dart';
import '../../models/sort_option.dart';
import '../../services/note_service.dart';
import 'modals/details_modal.dart';
import '../../services/detail_service.dart';
import '../../models/detail.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_text_styles.dart';
import '../../theme/app_component_styles.dart';

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
        SizedBox(height: 20 * scale),
        // 검색창
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: AppSpacing.horizontalPadding * scale,
            vertical: 20 * scale,
          ),
          child: TextField(
            style: AppTextStyles.bodyText.copyWith(fontSize: 30 * scale),
            decoration: AppComponentStyles.textInputDecoration(
              hintText: "검색어를 입력하세요.",
            ).copyWith(
              hintStyle: AppTextStyles.bodyText.copyWith(
                fontSize: 25 * scale,
                color: AppColors.primaryText.withOpacity(0.5),
              ),
              contentPadding: EdgeInsets.symmetric(
                horizontal: 30 * scale,
                vertical: 25 * scale,
              ),
            ),
            onChanged: (value) {
              setState(() {
                _searchQuery = value.isEmpty ? null : value;
              });
            },
          ),
        ),

        // 상세 필터 토글
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: AppSpacing.horizontalPadding * scale,
            vertical: 10 * scale,
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
            padding: EdgeInsets.symmetric(
              horizontal: AppSpacing.horizontalPadding * scale,
              vertical: 10 * scale,
            ),
            child: Container(
              decoration: AppComponentStyles.filterAreaDecoration.copyWith(
                borderRadius: BorderRadius.circular(AppSpacing.borderRadiusSmall * scale),
                border: Border.all(
                  color: AppColors.border,
                  width: AppSpacing.borderWidth * scale,
                ),
              ),
              padding: EdgeInsets.all(30 * scale),
              child: Column(
                children: [
                  _buildFilterSlider(
                    '산미',
                    (_filterAcidity ?? 5).toDouble(),
                    (value) => setState(() => _filterAcidity = value.toInt()),
                    scale,
                  ),
                  SizedBox(height: 30 * scale),
                  _buildFilterSlider(
                    '바디',
                    (_filterBody ?? 5).toDouble(),
                    (value) => setState(() => _filterBody = value.toInt()),
                    scale,
                  ),
                  SizedBox(height: 30 * scale),
                  _buildFilterSlider(
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

        // 정렬 버튼
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: AppSpacing.horizontalPadding * scale,
            vertical: 10 * scale,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              _sortButton("최신순", const DateSortOption(ascending: false), scale),
              SizedBox(width: 20 * scale),
              _sortButton("별점순", const ScoreSortOption(ascending: false), scale),
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
                    _buildEmptyGuideCard(scale),
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
                    child: _buildNoteCard(notes[index], scale),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _sortButton(String label, SortOption option, double scale) {
    bool isSelected = (_currentSort.runtimeType == option.runtimeType);

    return GestureDetector(
      onTap: () {
        setState(() {
          _currentSort = option;
        });
      },
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

  Widget _buildEmptyGuideCard(double scale) {
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
            Icon(
              Icons.coffee_outlined,
              size: 60 * scale,
              color: AppColors.border,
            ),
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

  Widget _buildNoteCard(Note note, double scale) {
      return GestureDetector(
          onTap: () {
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
          backgroundColor: Colors.transparent,
              builder: (context) => NoteDetailsModal(note: note),
            ).then((result) {
              if (result == true) {
                refreshNotes();
              }
            });
          },
      child: Container(
        decoration: AppComponentStyles.noteCardDecoration.copyWith(
          borderRadius: BorderRadius.circular(AppSpacing.borderRadiusSmall * scale),
          border: Border.all(
            color: AppColors.border,
            width: AppSpacing.borderWidth * scale,
          ),
        ),
        child: FutureBuilder<Detail?>(
          future: DetailService.instance.getDetailByNoteId(note.id),
          builder: (context, detailSnapshot) {
            final hasDetail = detailSnapshot.hasData && detailSnapshot.data != null;
            final detail = detailSnapshot.data;

            return Padding(
              padding: EdgeInsets.all(20 * scale),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 왼쪽: 카페명, 날짜, 메뉴명, 한줄평 (+ 상세 정보)
                  Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
                        // 카페명
                        Row(
                          children: [
                            Icon(
                              Icons.location_on,
                              size: 24 * scale,
                              color: AppColors.primaryText,
                            ),
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
                        SizedBox(height: 8 * scale),
                        // 날짜
                        Row(
                          children: [
                            Icon(
                              Icons.calendar_today,
                              size: 24 * scale,
                              color: AppColors.primaryText,
                            ),
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
                        SizedBox(height: 15 * scale),
                        // 메뉴명
                        Text(
                          note.menu,
                          style: AppTextStyles.largeTitle.copyWith(
                            fontSize: 50 * scale,
                            color: AppColors.primaryDark,
                          ),
                        ),
                        // 상세 정보 (detail_included의 경우)
                        if (hasDetail && detail != null) ...[
                          SizedBox(height: 10 * scale),
                          _buildDetailInfo(detail, scale),
                        ],
                        SizedBox(height: 15 * scale),
                        // 한줄평
                        Text(
                          note.comment,
                          style: AppTextStyles.bodyText.copyWith(
                            fontSize: 35 * scale,
                            color: AppColors.primaryText,
                          ),
                        ),
                        // 해시태그 (detail_included의 경우, 오른쪽 하단)
                        if (hasDetail && 
                            detail != null && 
                            detail.tastingNotes != null && 
                            detail.tastingNotes!.isNotEmpty) ...[
                          SizedBox(height: 15 * scale),
                          Align(
                            alignment: Alignment.centerRight,
                            child: Wrap(
                              spacing: 10 * scale,
                              runSpacing: 10 * scale,
                              children: detail.tastingNotes!.take(5).map((tag) => Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 20 * scale,
                                  vertical: 8 * scale,
                                ),
                                decoration: AppComponentStyles.hashtagDecoration.copyWith(
                                  borderRadius: BorderRadius.circular(
                                    AppSpacing.borderRadiusLarge * scale,
                                  ),
                                ),
                                child: Text(
                                  "#$tag",
                                  style: AppComponentStyles.hashtagTextStyle.copyWith(
                                    fontSize: 30 * scale,
                                  ),
                                ),
                              )).toList(),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  SizedBox(width: 20 * scale),
                  // 오른쪽: 산미, 바디, 쓴맛 수치
                  Container(
                    width: 200 * scale,
                    padding: EdgeInsets.symmetric(
                      horizontal: 20 * scale,
                      vertical: 20 * scale,
                    ),
                    decoration: AppComponentStyles.filterAreaDecoration.copyWith(
                      borderRadius: BorderRadius.circular(
                        AppSpacing.borderRadiusSmall * scale,
                      ),
                      border: Border.all(
                        color: AppColors.border,
                        width: AppSpacing.borderWidth * scale,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildLevelDisplay("산미", note.levelAcidity, scale),
                        SizedBox(height: 20 * scale),
                        _buildLevelDisplay("바디", note.levelBody, scale),
                        SizedBox(height: 20 * scale),
                        _buildLevelDisplay("쓴맛", note.levelBitterness, scale),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
                      ),
                    );
                  }

  Widget _buildDetailInfo(Detail detail, double scale) {
    final infoList = <String>[];
    
    if (detail.originLocation != null && detail.originLocation!.isNotEmpty) {
      infoList.add(detail.originLocation!);
    }
    if (detail.variety != null && detail.variety!.isNotEmpty) {
      infoList.add(detail.variety!);
    }
    if (detail.process != null) {
      infoList.add(detail.process!.displayName);
    }
    if (detail.roastingPoint != null) {
      infoList.add(detail.roastingPoint!.displayName);
    }
    if (detail.method != null) {
      infoList.add(detail.method!.displayName);
    }

    return Wrap(
      spacing: 10 * scale,
      runSpacing: 10 * scale,
      children: infoList.map((info) => Text(
        info,
        style: AppTextStyles.bodyText.copyWith(
          fontSize: 30 * scale,
          fontWeight: FontWeight.w300,
          color: AppColors.primaryText,
        ),
      )).toList(),
    );
  }

  Widget _buildLevelDisplay(String label, int value, double scale) {
    final starCount = (value / 2).ceil(); // 1-10을 1-5 별로 변환
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Flexible(
          flex: 2,
          child: Text(
            label,
            style: AppTextStyles.bodyText.copyWith(fontSize: 30 * scale),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        SizedBox(width: 6 * scale),
        Flexible(
          flex: 3,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: List.generate(5, (index) => Container(
              width: 10 * scale,
              height: 10 * scale,
              margin: EdgeInsets.only(right: index < 4 ? 1 * scale : 0),
              decoration: BoxDecoration(
                color: index < starCount ? AppColors.primaryDark : Colors.transparent,
                border: Border.all(
                  color: AppColors.primaryDark,
                  width: AppSpacing.borderWidth * scale,
                ),
                borderRadius: BorderRadius.circular(1.5 * scale),
              ),
            )),
          ),
        ),
      ],
    );
  }

  // 상세 필터용 슬라이더 빌더
  Widget _buildFilterSlider(
    String label,
    double value,
    ValueChanged<double> onChanged,
    double scale,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: AppTextStyles.bodyText.copyWith(
                fontSize: 30 * scale,
                fontWeight: FontWeight.w700,
                color: AppColors.primaryDark,
              ),
            ),
            Text(
              "${value.toInt()}",
              style: AppTextStyles.bodyText.copyWith(
                fontSize: 30 * scale,
                fontWeight: FontWeight.w700,
                color: AppColors.primaryDark,
              ),
            ),
          ],
        ),
        SizedBox(height: 10 * scale),
        Slider(
          value: value,
          min: 1,
          max: 10,
          divisions: 9,
          activeColor: AppColors.primaryDark,
          inactiveColor: Colors.grey[300],
          onChanged: onChanged,
        ),
      ],
    );
  }
}
