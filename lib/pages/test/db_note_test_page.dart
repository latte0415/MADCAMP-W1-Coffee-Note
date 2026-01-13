import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:image_picker/image_picker.dart';
import '../../services/note_service.dart';
import '../../services/image_service.dart';
import '../../models/note.dart';
import '../../models/sort_option.dart';

class DbTestPage extends StatefulWidget {
  const DbTestPage({super.key});

  @override
  State<DbTestPage> createState() => _DbTestPageState();
}

class _DbTestPageState extends State<DbTestPage> {
  List<Note> _notes = [];
  SortOption _currentSortOption = const DateSortOption(ascending: false);
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  Timer? _searchDebounce;
  
  // Similarity 필터 관련 상태
  bool _isRecommendationMode = false;
  final TextEditingController _acidityController = TextEditingController(text: '5');
  final TextEditingController _bodyController = TextEditingController(text: '5');
  final TextEditingController _bitternessController = TextEditingController(text: '5');
  final TextEditingController _limitController = TextEditingController(text: '5');

  @override
  void initState() {
    super.initState();
    _loadNotes();
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _searchController.dispose();
    _acidityController.dispose();
    _bodyController.dispose();
    _bitternessController.dispose();
    _limitController.dispose();
    super.dispose();
  }

  Future<void> _loadNotes() async {
    if (_isRecommendationMode) {
      await _loadRecommendedNotes();
      return;
    }
    
    List<Note> notes;
    if (_searchQuery.trim().isEmpty) {
      // 검색어가 없으면 전체 노트 가져오기
      notes = await NoteService.instance.getAllNotes(_currentSortOption);
    } else {
      // 검색어가 있으면 검색 실행
      notes = await NoteService.instance.searchNotes(_searchQuery.trim(), _currentSortOption);
    }
    setState(() {
      _notes = notes;
    });
  }

  Future<void> _loadRecommendedNotes() async {
    try {
      final acidity = int.tryParse(_acidityController.text) ?? 5;
      final body = int.tryParse(_bodyController.text) ?? 5;
      final bitterness = int.tryParse(_bitternessController.text) ?? 5;
      final limit = int.tryParse(_limitController.text) ?? 5;
      
      // 값 범위 검증 (1-10)
      final validAcidity = acidity.clamp(1, 10);
      final validBody = body.clamp(1, 10);
      final validBitterness = bitterness.clamp(1, 10);
      final validLimit = limit.clamp(1, 100);
      
      final notes = await NoteService.instance.getRecommendedNotes(
        validAcidity,
        validBody,
        validBitterness,
        limit: validLimit,
      );
      
      setState(() {
        _notes = notes;
      });
    } catch (e) {
      // 에러 처리
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('추천 노트 로드 실패: $e')),
        );
      }
    }
  }

  void _exitRecommendationMode() {
    setState(() {
      _isRecommendationMode = false;
    });
    _loadNotes();
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query;
    });
    
    // 이전 타이머 취소
    _searchDebounce?.cancel();
    
    // 500ms 후에 검색 실행 (debounce)
    _searchDebounce = Timer(const Duration(milliseconds: 500), () {
      _loadNotes();
    });
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() {
      _searchQuery = '';
    });
    _loadNotes();
  }

  Future<void> _createTestData() async {
    final now = DateTime.now();
    final testNotes = [
      // 다양한 점수와 날짜를 가진 테스트 데이터
      Note(
        id: const Uuid().v4(),
        location: 'Starbucks Gangnam',
        menu: 'Americano',
        levelAcidity: 5,
        levelBody: 3,
        levelBitterness: 4,
        comment: 'Delicious',
        score: 5,
        drankAt: now.subtract(const Duration(days: 10)),
      ),
      Note(
        id: const Uuid().v4(),
        location: 'Twosome Place',
        menu: 'Cafe Latte',
        levelAcidity: 3,
        levelBody: 5,
        levelBitterness: 2,
        comment: 'Just okay',
        score: 2,
        drankAt: now.subtract(const Duration(days: 5)),
      ),
      Note(
        id: const Uuid().v4(),
        location: 'EDIYA Coffee',
        menu: 'Vanilla Latte',
        levelAcidity: 2,
        levelBody: 4,
        levelBitterness: 3,
        comment: 'The best!',
        score: 4,
        drankAt: now.subtract(const Duration(days: 15)),
      ),
      Note(
        id: const Uuid().v4(),
        location: 'Hollys Coffee',
        menu: 'Cold Brew',
        levelAcidity: 4,
        levelBody: 5,
        levelBitterness: 5,
        comment: 'Not good',
        score: 1,
        drankAt: now.subtract(const Duration(days: 2)),
      ),
      Note(
        id: const Uuid().v4(),
        location: 'Compose Coffee',
        menu: 'Cappuccino',
        levelAcidity: 3,
        levelBody: 3,
        levelBitterness: 3,
        comment: 'Average',
        score: 3,
        drankAt: now.subtract(const Duration(days: 7)),
      ),
      Note(
        id: const Uuid().v4(),
        location: 'Mega Coffee',
        menu: 'Espresso',
        levelAcidity: 5,
        levelBody: 2,
        levelBitterness: 4,
        comment: 'Good',
        score: 4,
        drankAt: now.subtract(const Duration(days: 1)),
      ),
      Note(
        id: const Uuid().v4(),
        location: 'Paik\'s Coffee',
        menu: 'Iced Americano',
        levelAcidity: 2,
        levelBody: 2,
        levelBitterness: 2,
        comment: 'Not bad',
        score: 3,
        drankAt: now.subtract(const Duration(days: 20)),
      ),
      Note(
        id: const Uuid().v4(),
        location: 'Caffe Bene',
        menu: 'Caramel Macchiato',
        levelAcidity: 1,
        levelBody: 4,
        levelBitterness: 1,
        comment: 'Excellent!',
        score: 5,
        drankAt: now.subtract(const Duration(days: 3)),
      ),
    ];

    for (final note in testNotes) {
      await NoteService.instance.createNote(note);
    }

    _loadNotes();
  }

  Future<void> _sortByDate(bool ascending) async {
    setState(() {
      _currentSortOption = DateSortOption(ascending: ascending);
    });
    _loadNotes();
  }

  Future<void> _sortByScore(bool ascending) async {
    setState(() {
      _currentSortOption = ScoreSortOption(ascending: ascending);
    });
    _loadNotes();
  }

  Future<void> _createNote() async {
    // 이미지 선택 다이얼로그
    final imageSource = await _showImageSourceDialog();
    XFile? selectedImage;
    
    if (imageSource != null) {
      selectedImage = await ImageService.instance.pickImage(imageSource);
    }

    final noteId = const Uuid().v4();
    String? imagePath;

    // 이미지가 선택된 경우 저장
    if (selectedImage != null) {
      imagePath = await ImageService.instance.saveImage(selectedImage, noteId);
    }

    final note = Note(
      id: noteId,
      location: 'Test Cafe',
      menu: 'Americano',
      levelAcidity: 3,
      levelBody: 4,
      levelBitterness: 2,
      comment: 'Test',
      score: 3,
      drankAt: DateTime.now(),
      image: imagePath,
    );

    await NoteService.instance.createNote(note);
    _loadNotes();
  }

  Future<ImageSource?> _showImageSourceDialog() async {
    return await showDialog<ImageSource>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('이미지 선택'),
        content: const Text('이미지를 선택하세요'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, ImageSource.gallery),
            child: const Text('갤러리'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, ImageSource.camera),
            child: const Text('카메라'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, null),
            child: const Text('취소'),
          ),
        ],
      ),
    );
  }

  Future<void> _updateNote(Note note) async {
    // 이미지 변경 여부 확인
    final imageSource = await _showImageSourceDialog();
    XFile? selectedImage;
    String? imagePath = note.image;

    if (imageSource != null) {
      selectedImage = await ImageService.instance.pickImage(imageSource);
      
      // 새 이미지가 선택된 경우 저장
      if (selectedImage != null) {
        imagePath = await ImageService.instance.saveImage(selectedImage, note.id);
      }
    }

    final updatedNote = Note(
      id: note.id,
      location: note.location,
      menu: '${note.menu} (Updated)',
      levelAcidity: note.levelAcidity,
      levelBody: note.levelBody,
      levelBitterness: note.levelBitterness,
      comment: '${note.comment} - Update test',
      score: note.score + 1 > 5 ? 5 : note.score + 1,
      drankAt: note.drankAt,
      createdAt: note.createdAt,
      image: imagePath,
    );

    await NoteService.instance.updateNote(updatedNote);
    _loadNotes();
  }

  Future<void> _deleteNote(String id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('삭제 확인'),
        content: const Text('이 노트를 삭제하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('삭제'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await NoteService.instance.deleteNote(id);
      _loadNotes();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('DB 테스트')),
      body: Column(
        children: [
          // 검색바
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              enabled: !_isRecommendationMode,
              keyboardType: TextInputType.text,
              textInputAction: TextInputAction.search,
              enableInteractiveSelection: true,
              enableSuggestions: true,
              autocorrect: true,
              obscureText: false,
              maxLines: 1,
              textCapitalization: TextCapitalization.none,
              decoration: InputDecoration(
                hintText: _isRecommendationMode 
                    ? '추천 모드에서는 검색이 비활성화됩니다'
                    : '카페명, 메뉴, 코멘트로 검색...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty && !_isRecommendationMode
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: _clearSearch,
                        tooltip: '검색 초기화',
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                filled: true,
                fillColor: _isRecommendationMode ? Colors.grey[200] : Colors.grey[100],
              ),
              onChanged: _onSearchChanged,
            ),
          ),
          // 상단 버튼 영역 (스크롤 가능)
          Expanded(
            flex: 0,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // 검색 결과 표시
                  if (_searchQuery.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      color: Colors.blue[50],
                      child: Row(
                        children: [
                          Icon(Icons.search, size: 16, color: Colors.blue[700]),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              '"$_searchQuery" 검색 결과: ${_notes.length}개',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.blue[700],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  // 테스트 데이터 생성 버튼
                  ElevatedButton(
                    onPressed: _createTestData,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('테스트 데이터 생성 (다양한 점수/날짜)'),
                  ),
                  const SizedBox(height: 8),
                  // 기본 노트 생성 버튼
                  ElevatedButton(
                    onPressed: _createNote,
                    child: const Text('노트 생성'),
                  ),
                  const SizedBox(height: 8),
                  // 정렬 옵션 버튼들
                  if (!_isRecommendationMode)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                      Column(
                        children: [
                          const Text('날짜순', style: TextStyle(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              ElevatedButton(
                                onPressed: () => _sortByDate(false),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: _currentSortOption is DateSortOption && !_currentSortOption.ascending
                                      ? Colors.green
                                      : null,
                                ),
                                child: const Text('↓ 최신순'),
                              ),
                              const SizedBox(width: 4),
                              ElevatedButton(
                                onPressed: () => _sortByDate(true),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: _currentSortOption is DateSortOption && _currentSortOption.ascending
                                      ? Colors.green
                                      : null,
                                ),
                                child: const Text('↑ 오래된순'),
                              ),
                            ],
                          ),
                        ],
                      ),
                      Column(
                        children: [
                          const Text('점수순', style: TextStyle(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              ElevatedButton(
                                onPressed: () => _sortByScore(false),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: _currentSortOption is ScoreSortOption && !_currentSortOption.ascending
                                      ? Colors.green
                                      : null,
                                ),
                                child: const Text('↓ 높은순'),
                              ),
                              const SizedBox(width: 4),
                              ElevatedButton(
                                onPressed: () => _sortByScore(true),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: _currentSortOption is ScoreSortOption && _currentSortOption.ascending
                                      ? Colors.green
                                      : null,
                                ),
                                child: const Text('↑ 낮은순'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                  if (!_isRecommendationMode) const SizedBox(height: 8),
                  // 현재 정렬 상태 표시
                  if (!_isRecommendationMode)
                    Container(
                      padding: const EdgeInsets.all(8),
                      color: Colors.grey[200],
                      child: Text(
                        '현재 정렬: ${_currentSortOption is DateSortOption ? "날짜" : "점수"} (${_currentSortOption.ascending ? "오름차순" : "내림차순"})',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  const SizedBox(height: 8),
                  // Similarity 필터 섹션
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: _isRecommendationMode ? Colors.orange[50] : Colors.grey[100],
                      border: Border.all(
                        color: _isRecommendationMode ? Colors.orange : Colors.grey,
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.recommend,
                              color: _isRecommendationMode ? Colors.orange[700] : Colors.grey,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Similarity 필터 테스트',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: _isRecommendationMode ? Colors.orange[700] : Colors.grey[700],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        if (_isRecommendationMode) ...[
                          // 추천 모드일 때: 현재 필터 값 표시 및 해제 버튼
                          Container(
                            padding: const EdgeInsets.all(8),
                            color: Colors.white,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '산미: ${_acidityController.text} | 바디: ${_bodyController.text} | 쓴맛: ${_bitternessController.text} | Limit: ${_limitController.text}',
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  '추천 결과: ${_notes.length}개',
                                  style: TextStyle(color: Colors.orange[700]),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 8),
                          ElevatedButton.icon(
                            onPressed: _exitRecommendationMode,
                            icon: const Icon(Icons.close),
                            label: const Text('추천 모드 해제'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              foregroundColor: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 8),
                          ElevatedButton.icon(
                            onPressed: _loadRecommendedNotes,
                            icon: const Icon(Icons.refresh),
                            label: const Text('다시 검색'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orange,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ] else ...[
                          // 일반 모드일 때: 입력 필드 및 검색 버튼
                          Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: _acidityController,
                                  keyboardType: TextInputType.number,
                                  decoration: const InputDecoration(
                                    labelText: '산미 (1-10)',
                                    border: OutlineInputBorder(),
                                    isDense: true,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: TextField(
                                  controller: _bodyController,
                                  keyboardType: TextInputType.number,
                                  decoration: const InputDecoration(
                                    labelText: '바디 (1-10)',
                                    border: OutlineInputBorder(),
                                    isDense: true,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: TextField(
                                  controller: _bitternessController,
                                  keyboardType: TextInputType.number,
                                  decoration: const InputDecoration(
                                    labelText: '쓴맛 (1-10)',
                                    border: OutlineInputBorder(),
                                    isDense: true,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: _limitController,
                                  keyboardType: TextInputType.number,
                                  decoration: const InputDecoration(
                                    labelText: 'Limit (1-100)',
                                    border: OutlineInputBorder(),
                                    isDense: true,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              ElevatedButton.icon(
                                onPressed: () {
                                  setState(() {
                                    _isRecommendationMode = true;
                                  });
                                  _loadRecommendedNotes();
                                },
                                icon: const Icon(Icons.search),
                                label: const Text('추천 검색'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.orange,
                                  foregroundColor: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          // 노트 리스트 영역 (스크롤 가능)
          Expanded(
            child: _notes.isEmpty
                ? const Center(child: Text('노트가 없습니다.'))
                : ListView.builder(
                    itemCount: _notes.length,
                    itemBuilder: (context, index) {
                      final note = _notes[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        child: ExpansionTile(
                          title: Text(
                            note.menu,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text('${note.location} | 점수: ${note.score}/5'),
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildInfoRow('ID', note.id),
                                  _buildInfoRow('위치', note.location),
                                  _buildInfoRow('메뉴', note.menu),
                                  _buildInfoRow('산미', '${note.levelAcidity}/10'),
                                  _buildInfoRow('바디', '${note.levelBody}/10'),
                                  _buildInfoRow('쓴맛', '${note.levelBitterness}/10'),
                                  _buildInfoRow('점수', '${note.score}/5'),
                                  _buildInfoRow('코멘트', note.comment),
                                  _buildInfoRow(
                                    '마신 날짜',
                                    '${note.drankAt.year}-${note.drankAt.month.toString().padLeft(2, '0')}-${note.drankAt.day.toString().padLeft(2, '0')}',
                                  ),
                                  _buildInfoRow(
                                    '생성일',
                                    '${note.createdAt.year}-${note.createdAt.month.toString().padLeft(2, '0')}-${note.createdAt.day.toString().padLeft(2, '0')} ${note.createdAt.hour.toString().padLeft(2, '0')}:${note.createdAt.minute.toString().padLeft(2, '0')}',
                                  ),
                                  _buildInfoRow(
                                    '수정일',
                                    '${note.updatedAt.year}-${note.updatedAt.month.toString().padLeft(2, '0')}-${note.updatedAt.day.toString().padLeft(2, '0')} ${note.updatedAt.hour.toString().padLeft(2, '0')}:${note.updatedAt.minute.toString().padLeft(2, '0')}',
                                  ),
                                  if (note.image != null) ...[
                                    const SizedBox(height: 8),
                                    const Text(
                                      '이미지:',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.grey,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: Image.file(
                                        File(note.image!),
                                        width: double.infinity,
                                        height: 200,
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error, stackTrace) {
                                          return Container(
                                            height: 200,
                                            color: Colors.grey[300],
                                            child: const Center(
                                              child: Icon(Icons.broken_image, size: 48),
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                  ],
                                  const SizedBox(height: 16),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      TextButton.icon(
                                        onPressed: () => _updateNote(note),
                                        icon: const Icon(Icons.edit),
                                        label: const Text('수정'),
                                      ),
                                      const SizedBox(width: 8),
                                      TextButton.icon(
                                        onPressed: () => _deleteNote(note.id),
                                        icon: const Icon(Icons.delete),
                                        label: const Text('삭제'),
                                        style: TextButton.styleFrom(
                                          foregroundColor: Colors.red,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }
}