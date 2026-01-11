import 'dart:math';
import 'package:flutter/material.dart';
import '../../models/note.dart';
import '../../models/sort_option.dart';
import '../../services/note_service.dart';
import 'modals/details_modal.dart';
import '../../services/detail_service.dart';
import '../../models/detail.dart';

class ListPage extends StatefulWidget {
  const ListPage({super.key});

  @override
  State<ListPage> createState() => ListPageState();
}

class ListPageState extends State<ListPage> {
  // 디자인 시스템 색상 상수
  static const Color _primaryDark = Color(0xFF2B1E1A);
  static const Color _background = Color(0xFFFFFFFF);
  static const Color _borderColor = Color.fromRGBO(90, 58, 46, 0.3);

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
    return Column(
      children: [
        // 검색창
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 49, vertical: 20),
          child: TextField(
            style: const TextStyle(
              fontSize: 50,
              fontWeight: FontWeight.w400,
              color: _primaryDark,
              letterSpacing: 0.1,
            ),
            decoration: InputDecoration(
              hintText: "검색어를 입력하세요.",
              hintStyle: TextStyle(
                fontSize: 50,
                fontWeight: FontWeight.w400,
                color: Colors.grey[400],
                letterSpacing: 0.1,
              ),
              filled: true,
              fillColor: Colors.grey[100],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 30, vertical: 25),
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
          padding: const EdgeInsets.symmetric(horizontal: 49, vertical: 10),
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
                  color: _primaryDark,
                  size: 30,
                ),
                label: const Text(
                  "상세필터",
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.w400,
                    color: _primaryDark,
                    letterSpacing: 0.1,
                  ),
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
                  child: const Text(
                    "초기화",
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.w400,
                      color: _primaryDark,
                      letterSpacing: 0.1,
                    ),
                  ),
                ),
            ],
          ),
        ),

        // 상세 필터 슬라이더 (spread 상태)
        if (_showDetailFilter) ...[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 49, vertical: 10),
            child: Container(
              decoration: BoxDecoration(
                color: _background,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: _borderColor, width: 2),
              ),
              padding: const EdgeInsets.all(30),
              child: Column(
                children: [
                  _buildFilterSlider(
                    '산미',
                    (_filterAcidity ?? 5).toDouble(),
                    (value) => setState(() => _filterAcidity = value.toInt()),
                  ),
                  const SizedBox(height: 30),
                  _buildFilterSlider(
                    '바디',
                    (_filterBody ?? 5).toDouble(),
                    (value) => setState(() => _filterBody = value.toInt()),
                  ),
                  const SizedBox(height: 30),
                  _buildFilterSlider(
                    '쓴맛',
                    (_filterBitterness ?? 5).toDouble(),
                    (value) => setState(() => _filterBitterness = value.toInt()),
                  ),
                ],
              ),
            ),
          ),
        ],

        // 정렬 버튼
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 49, vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              _sortButton("최신순", const DateSortOption(ascending: false)),
              const SizedBox(width: 20),
              _sortButton("별점순", const ScoreSortOption(ascending: false)),
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
                  padding: const EdgeInsets.symmetric(horizontal: 49),
                  children: [
                    _buildEmptyGuideCard(),
                  ],
                );
              }

              final notes = snapshot.data!;
              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 49, vertical: 20),
                itemCount: notes.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 30),
                    child: _buildNoteCard(notes[index]),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _sortButton(String label, SortOption option) {
    bool isSelected = (_currentSort.runtimeType == option.runtimeType);

    return GestureDetector(
      onTap: () {
        setState(() {
          _currentSort = option;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
        decoration: BoxDecoration(
          color: isSelected ? _primaryDark : Colors.grey[400],
          borderRadius: BorderRadius.circular(26),
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.w400,
            color: _background,
            letterSpacing: 0.1,
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyGuideCard() {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 20),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey[300]!, width: 1),
      ),
      child: Container(
        padding: const EdgeInsets.all(40),
        child: Column(
          children: [
            const Icon(Icons.coffee_outlined, size: 60, color: Colors.grey),
            const SizedBox(height: 20),
            const Text(
              "아직 작성된 노트가 없어요",
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.w700,
                color: Colors.grey,
                letterSpacing: 0.1,
              ),
            ),
            const SizedBox(height: 15),
            const Text(
              "하단의 + 버튼을 눌러\n첫 번째 커피 노트를 만들어보세요!",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 25,
                color: Colors.grey,
                letterSpacing: 0.1,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoteCard(Note note) {
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
        decoration: BoxDecoration(
          color: _background,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: _borderColor, width: 2),
        ),
        child: FutureBuilder<Detail?>(
          future: DetailService.instance.getDetailByNoteId(note.id),
          builder: (context, detailSnapshot) {
            final hasDetail = detailSnapshot.hasData && detailSnapshot.data != null;
            final detail = detailSnapshot.data;

            return Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 왼쪽: 카페명, 날짜, 메뉴명, 한줄평 (+ 상세 정보)
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 카페명
                        Text(
                          note.location,
                          style: const TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.w300,
                            color: Color(0xFF262626),
                            letterSpacing: 0.1,
                          ),
                        ),
                        const SizedBox(height: 8),
                        // 날짜
                        Text(
                          note.drankAt.toString().split(' ')[0],
                          style: const TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.w300,
                            color: Color(0xFF262626),
                            letterSpacing: 0.1,
                          ),
                        ),
                        const SizedBox(height: 15),
                        // 메뉴명
                        Text(
                          note.menu,
                          style: const TextStyle(
                            fontSize: 50,
                            fontWeight: FontWeight.w700,
                            color: _primaryDark,
                            letterSpacing: 0.1,
                          ),
                        ),
                        // 상세 정보 (detail_included의 경우)
                        if (hasDetail && detail != null) ...[
                          const SizedBox(height: 10),
                          _buildDetailInfo(detail),
                        ],
                        const SizedBox(height: 15),
                        // 한줄평
                        Text(
                          note.comment,
                          style: const TextStyle(
                            fontSize: 35,
                            fontWeight: FontWeight.w400,
                            color: Color(0xFF262626),
                            letterSpacing: 0.1,
                          ),
                        ),
                        // 해시태그 (detail_included의 경우, 오른쪽 하단)
                        if (hasDetail && 
                            detail != null && 
                            detail.tastingNotes != null && 
                            detail.tastingNotes!.isNotEmpty) ...[
                          const SizedBox(height: 15),
                          Align(
                            alignment: Alignment.centerRight,
                            child: Wrap(
                              spacing: 10,
                              runSpacing: 10,
                              children: detail.tastingNotes!.take(5).map((tag) => Container(
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                                decoration: BoxDecoration(
                                  color: _primaryDark,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  "#$tag",
                                  style: const TextStyle(
                                    fontSize: 30,
                                    fontWeight: FontWeight.w400,
                                    color: _background,
                                    letterSpacing: 0.1,
                                  ),
                                ),
                              )).toList(),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(width: 20),
                  // 오른쪽: 산미, 바디, 쓴맛 수치
                  Container(
                    width: 200,
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: _background,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: _borderColor, width: 2),
                    ),
                    child: Column(
                      children: [
                        _buildLevelDisplay("산미", note.levelAcidity),
                        const SizedBox(height: 25),
                        _buildLevelDisplay("바디", note.levelBody),
                        const SizedBox(height: 25),
                        _buildLevelDisplay("쓴맛", note.levelBitterness),
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

  Widget _buildDetailInfo(Detail detail) {
    final infoList = <String>[];
    
    if (detail.originCountry != null && detail.originCountry!.isNotEmpty) {
      infoList.add(detail.originCountry!);
    }
    if (detail.variety != null && detail.variety!.isNotEmpty) {
      infoList.add(detail.variety!);
    }
    infoList.add(detail.process.displayName);
    infoList.add(detail.roastingPoint.displayName);
    infoList.add(detail.method.displayName);

    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: infoList.map((info) => Text(
        info,
        style: const TextStyle(
          fontSize: 30,
          fontWeight: FontWeight.w300,
          color: Color(0xFF262626),
          letterSpacing: 0.1,
        ),
      )).toList(),
    );
  }

  Widget _buildLevelDisplay(String label, int value) {
    final starCount = (value / 2).ceil(); // 1-10을 1-5 별로 변환
    
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.w400,
            color: _primaryDark,
            letterSpacing: 0.1,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(5, (index) => Container(
            width: 20,
            height: 20,
            margin: const EdgeInsets.symmetric(horizontal: 2),
            decoration: BoxDecoration(
              color: index < starCount ? _primaryDark : Colors.transparent,
              border: Border.all(color: _primaryDark, width: 2),
              borderRadius: BorderRadius.circular(4),
            ),
          )),
        ),
      ],
    );
  }

  // 상세 필터용 슬라이더 빌더
  Widget _buildFilterSlider(
    String label,
    double value,
    ValueChanged<double> onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.w700,
                color: _primaryDark,
                letterSpacing: 0.1,
              ),
            ),
            Text(
              "${value.toInt()}",
              style: const TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.w700,
                color: _primaryDark,
                letterSpacing: 0.1,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Slider(
          value: value,
          min: 1,
          max: 10,
          divisions: 9,
          activeColor: _primaryDark,
          inactiveColor: Colors.grey[300],
          onChanged: onChanged,
        ),
      ],
    );
  }
}
