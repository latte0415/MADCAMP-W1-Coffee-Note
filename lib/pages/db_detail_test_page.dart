import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../services/detail_service.dart';
import '../services/note_service.dart';
import '../models/detail.dart';
import '../models/note.dart';
import '../models/sort_option.dart';
import '../models/enums/process_type.dart';
import '../models/enums/roasting_point_type.dart';
import '../models/enums/method_type.dart';

class DbDetailTestPage extends StatefulWidget {
  const DbDetailTestPage({super.key});

  @override
  State<DbDetailTestPage> createState() => _DbDetailTestPageState();
}

class _DbDetailTestPageState extends State<DbDetailTestPage> {
  List<Note> _notes = [];
  Note? _selectedNote;
  Detail? _currentDetail;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadNotes();
  }

  Future<void> _loadNotes() async {
    final notes = await NoteService.instance.getAllNotes(const DateSortOption(ascending: false));
    setState(() {
      _notes = notes;
      if (_notes.isNotEmpty && _selectedNote == null) {
        _selectedNote = _notes.first;
        _loadDetail();
      }
    });
  }

  Future<void> _loadDetail() async {
    if (_selectedNote == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final detail = await DetailService.instance.getDetailByNoteId(_selectedNote!.id);
      setState(() {
        _currentDetail = detail;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _currentDetail = null;
        _isLoading = false;
      });
    }
  }

  Future<void> _createDetail() async {
    if (_selectedNote == null) {
      _showError('Note를 먼저 선택해주세요.');
      return;
    }

    // Detail 생성 다이얼로그
    final result = await _showDetailFormDialog();
    if (result != null) {
      try {
        await DetailService.instance.createDetail(result);
        _loadDetail();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Detail이 생성되었습니다.')),
          );
        }
      } catch (e) {
        _showError('Detail 생성 실패: $e');
      }
    }
  }

  Future<void> _updateDetail() async {
    if (_currentDetail == null) {
      _showError('수정할 Detail이 없습니다.');
      return;
    }

    final result = await _showDetailFormDialog(initialDetail: _currentDetail);
    if (result != null) {
      try {
        await DetailService.instance.updateDetail(result);
        _loadDetail();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Detail이 수정되었습니다.')),
          );
        }
      } catch (e) {
        _showError('Detail 수정 실패: $e');
      }
    }
  }

  Future<void> _deleteDetail() async {
    if (_currentDetail == null) {
      _showError('삭제할 Detail이 없습니다.');
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('삭제 확인'),
        content: const Text('이 Detail을 삭제하시겠습니까?'),
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
      try {
        await DetailService.instance.deleteDetail(_currentDetail!.id);
        _loadDetail();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Detail이 삭제되었습니다.')),
          );
        }
      } catch (e) {
        _showError('Detail 삭제 실패: $e');
      }
    }
  }

  Future<void> _createTestData() async {
    if (_notes.isEmpty) {
      _showError('먼저 Note를 생성해주세요.');
      return;
    }

    final testDetails = <Detail>[];
    final processTypes = ProcessType.values;
    final roastingTypes = RoastingPointType.values;
    final methodTypes = MethodType.values;

    // 최대 5개의 Note에 대해 Detail 생성
    final notesToUse = _notes.take(5).toList();

    for (int i = 0; i < notesToUse.length; i++) {
      final note = notesToUse[i];
      
      // 이미 Detail이 있는지 확인
      final existing = await DetailService.instance.getDetailByNoteId(note.id);
      if (existing != null) continue;

      final country = ['브라질', '에티오피아', '콜롬비아', '케냐', '과테말라'][i % 5];
      final region = ['세하도', '예가체프', '수프리모', 'AA', '안티구아'][i % 5];
      testDetails.add(Detail(
        id: const Uuid().v4(),
        noteId: note.id,
        originLocation: '$country $region',
        variety: ['아라비카', '게이샤', '버번', '티피카', '카투라'][i % 5],
        process: processTypes[i % processTypes.length],
        processText: '${processTypes[i % processTypes.length].displayName} 처리 방식',
        roastingPoint: roastingTypes[i % roastingTypes.length],
        roastingPointText: '${roastingTypes[i % roastingTypes.length].displayName} 로스팅',
        method: methodTypes[i % methodTypes.length],
        methodText: '${methodTypes[i % methodTypes.length].displayName} 추출',
      ));
    }

    int successCount = 0;
    for (final detail in testDetails) {
      try {
        await DetailService.instance.createDetail(detail);
        successCount++;
      } catch (e) {
        // 이미 존재하는 경우 등 에러 무시
      }
    }

    _loadDetail();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$successCount개의 테스트 Detail이 생성되었습니다.')),
      );
    }
  }

  Future<Detail?> _showDetailFormDialog({Detail? initialDetail}) async {
    final noteId = initialDetail?.noteId ?? _selectedNote?.id ?? '';
    
    // Note 선택 (수정 시에는 변경 불가)
    Note? selectedNoteForDetail = _selectedNote;
    if (initialDetail == null && _notes.isNotEmpty) {
      // 생성 시 Note 선택 가능
      selectedNoteForDetail = await _showNoteSelectionDialog();
      if (selectedNoteForDetail == null) return null;
    }

    final noteIdController = TextEditingController(text: selectedNoteForDetail?.id ?? noteId);
    final originLocationController = TextEditingController(text: initialDetail?.originLocation ?? '');
    final varietyController = TextEditingController(text: initialDetail?.variety ?? '');
    final processTextController = TextEditingController(text: initialDetail?.processText ?? '');
    final roastingPointTextController = TextEditingController(text: initialDetail?.roastingPointText ?? '');
    final methodTextController = TextEditingController(text: initialDetail?.methodText ?? '');

    ProcessType selectedProcess = initialDetail?.process ?? ProcessType.washed;
    RoastingPointType selectedRoastingPoint = initialDetail?.roastingPoint ?? RoastingPointType.medium;
    MethodType selectedMethod = initialDetail?.method ?? MethodType.filter;

    return await showDialog<Detail>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(initialDetail == null ? 'Detail 생성' : 'Detail 수정'),
          content: SingleChildScrollView(
            child: SizedBox(
              width: double.maxFinite,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Note ID (읽기 전용)
                  TextField(
                    controller: noteIdController,
                    enabled: false,
                    decoration: const InputDecoration(
                      labelText: 'Note ID',
                      hintText: 'Note ID',
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Origin Location
                  TextField(
                    controller: originLocationController,
                    decoration: const InputDecoration(
                      labelText: '원산지',
                      hintText: '예: 브라질 세하도',
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Variety
                  TextField(
                    controller: varietyController,
                    decoration: const InputDecoration(
                      labelText: '품종',
                      hintText: '예: 아라비카',
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Process Type
                  DropdownButtonFormField<ProcessType>(
                    value: selectedProcess,
                    decoration: const InputDecoration(labelText: '처리 방식 *'),
                    items: ProcessType.values.map((type) {
                      return DropdownMenuItem(
                        value: type,
                        child: Text(type.displayName),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setDialogState(() {
                          selectedProcess = value;
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 8),
                  // Process Text
                  TextField(
                    controller: processTextController,
                    decoration: const InputDecoration(
                      labelText: '처리 방식 설명',
                      hintText: '예: 워시드 처리 방식',
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Roasting Point Type
                  DropdownButtonFormField<RoastingPointType>(
                    value: selectedRoastingPoint,
                    decoration: const InputDecoration(labelText: '로스팅 포인트 *'),
                    items: RoastingPointType.values.map((type) {
                      return DropdownMenuItem(
                        value: type,
                        child: Text(type.displayName),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setDialogState(() {
                          selectedRoastingPoint = value;
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 8),
                  // Roasting Point Text
                  TextField(
                    controller: roastingPointTextController,
                    decoration: const InputDecoration(
                      labelText: '로스팅 포인트 설명',
                      hintText: '예: 미디엄 로스팅',
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Method Type
                  DropdownButtonFormField<MethodType>(
                    value: selectedMethod,
                    decoration: const InputDecoration(labelText: '추출 방식 *'),
                    items: MethodType.values.map((type) {
                      return DropdownMenuItem(
                        value: type,
                        child: Text(type.displayName),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setDialogState(() {
                          selectedMethod = value;
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 8),
                  // Method Text
                  TextField(
                    controller: methodTextController,
                    decoration: const InputDecoration(
                      labelText: '추출 방식 설명',
                      hintText: '예: 필터 추출',
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('취소'),
            ),
            TextButton(
              onPressed: () {
                if (noteIdController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Note ID는 필수입니다.')),
                  );
                  return;
                }

                final detail = Detail(
                  id: initialDetail?.id ?? const Uuid().v4(),
                  noteId: noteIdController.text,
                  originLocation: originLocationController.text.isEmpty ? null : originLocationController.text,
                  variety: varietyController.text.isEmpty ? null : varietyController.text,
                  process: selectedProcess,
                  processText: processTextController.text.isEmpty ? null : processTextController.text,
                  roastingPoint: selectedRoastingPoint,
                  roastingPointText: roastingPointTextController.text.isEmpty ? null : roastingPointTextController.text,
                  method: selectedMethod,
                  methodText: methodTextController.text.isEmpty ? null : methodTextController.text,
                );
                Navigator.of(context).pop(detail);
              },
              child: const Text('저장'),
            ),
          ],
        ),
      ),
    );
  }

  Future<Note?> _showNoteSelectionDialog() async {
    if (_notes.isEmpty) return null;

    Note? selectedNote;
    return await showDialog<Note>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Note 선택'),
          content: SizedBox(
            width: double.maxFinite,
            child: DropdownButtonFormField<Note>(
              value: selectedNote ?? _notes.first,
              decoration: const InputDecoration(labelText: 'Note 선택'),
              items: _notes.map((note) {
                return DropdownMenuItem(
                  value: note,
                  child: Text('${note.menu} - ${note.location}'),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setDialogState(() {
                    selectedNote = value;
                  });
                }
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('취소'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(selectedNote ?? _notes.first),
              child: const Text('선택'),
            ),
          ],
        ),
      ),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detail 테스트')),
      body: Column(
        children: [
          // Note 선택 영역
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.grey[100],
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<Note>(
                        value: _selectedNote,
                        decoration: const InputDecoration(
                          labelText: 'Note 선택',
                          border: OutlineInputBorder(),
                        ),
                        items: _notes.map((note) {
                          return DropdownMenuItem(
                            value: note,
                            child: Text('${note.menu} - ${note.location}'),
                          );
                        }).toList(),
                        onChanged: (note) {
                          setState(() {
                            _selectedNote = note;
                          });
                          _loadDetail();
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.refresh),
                      onPressed: () {
                        _loadNotes();
                        _loadDetail();
                      },
                      tooltip: '새로고침',
                    ),
                  ],
                ),
                if (_notes.isEmpty)
                  const Padding(
                    padding: EdgeInsets.only(top: 8),
                    child: Text(
                      'Note가 없습니다. 먼저 Note를 생성해주세요.',
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
              ],
            ),
          ),
          // 버튼 영역
          Container(
            padding: const EdgeInsets.all(8),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ElevatedButton.icon(
                  onPressed: _notes.isEmpty ? null : _createDetail,
                  icon: const Icon(Icons.add),
                  label: const Text('Detail 생성'),
                ),
                ElevatedButton.icon(
                  onPressed: _currentDetail == null ? null : _updateDetail,
                  icon: const Icon(Icons.edit),
                  label: const Text('Detail 수정'),
                ),
                ElevatedButton.icon(
                  onPressed: _currentDetail == null ? null : _deleteDetail,
                  icon: const Icon(Icons.delete),
                  label: const Text('Detail 삭제'),
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.red,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: _notes.isEmpty ? null : _createTestData,
                  icon: const Icon(Icons.data_object),
                  label: const Text('테스트 데이터 생성'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          // Detail 정보 표시 영역
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _currentDetail == null
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.info_outline, size: 48, color: Colors.grey),
                            const SizedBox(height: 16),
                            Text(
                              _selectedNote == null
                                  ? 'Note를 선택해주세요.'
                                  : '이 Note에 대한 Detail이 없습니다.',
                              style: const TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                      )
                    : SingleChildScrollView(
                        child: Card(
                          margin: const EdgeInsets.all(16),
                          child: ExpansionTile(
                            initiallyExpanded: true,
                            title: const Text(
                              'Detail 정보',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _buildInfoRow('ID', _currentDetail!.id),
                                    _buildInfoRow('Note ID', _currentDetail!.noteId),
                                    _buildInfoRow('원산지', _currentDetail!.originLocation ?? '(없음)'),
                                    _buildInfoRow('품종', _currentDetail!.variety ?? '(없음)'),
                                    _buildInfoRow('처리 방식', _currentDetail!.process?.displayName ?? '(없음)'),
                                    _buildInfoRow('처리 방식 설명', _currentDetail!.processText ?? '(없음)'),
                                    _buildInfoRow('로스팅 포인트', _currentDetail!.roastingPoint?.displayName ?? '(없음)'),
                                    _buildInfoRow('로스팅 포인트 설명', _currentDetail!.roastingPointText ?? '(없음)'),
                                    _buildInfoRow('추출 방식', _currentDetail!.method?.displayName ?? '(없음)'),
                                    _buildInfoRow('추출 방식 설명', _currentDetail!.methodText ?? '(없음)'),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
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
            width: 120,
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
