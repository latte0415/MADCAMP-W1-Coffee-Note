import 'dart:io';
import 'package:flutter/material.dart';
import '../models/note.dart';
import '../models/sort_option.dart';
import '../services/note_service.dart';
import '../pages/modals/details_modal.dart';
import '../../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../../widget/page_widget.dart';

class GalleryPage extends StatefulWidget {
  const GalleryPage({super.key});

  @override
  State<GalleryPage> createState() => GalleryPageState();
}

class GalleryPageState extends State<GalleryPage> {
  // 현재 오버레이가 켜져 있는 노트의 ID를 저장
  String? _activeNoteId;

  // 외부(MainPage)에서 새로고침할 수 있도록 함수 공개
  void refresh() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Note>>(
      // 최신 날짜순으로 데이터를 가져옵니다.
      future: NoteService.instance.getAllNotes(
          const DateSortOption(ascending: false)),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final notesWithImage = snapshot.data
            ?.where((note) => note.image != null && note.image!.isNotEmpty)
            .toList() ?? [];

        // [수정] 필터링된 결과가 없을 때 메시지 표시
        if (notesWithImage.isEmpty) {
          return const Center(child: Text("사진이 등록된 커피 노트가 없어요 📸"));
        }

        final allNotes = snapshot.data ?? [];

        if (allNotes.isEmpty) {
          return const Center(child: Text("아직 작성된 노트가 없어요"));
        }

        return GridView.builder(
          padding: const EdgeInsets.all(2),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 2,
            mainAxisSpacing: 2,
            childAspectRatio: 1, // 정사각형
          ),
          itemCount: notesWithImage.length,
          itemBuilder: (context, index) {
            final note = notesWithImage[index];
            // return _buildGalleryItem(note);
            return _GalleryTile(
              note: note,
              // 현재 이 노트의 ID가 활성화된 ID와 같은지 확인 [cite: 1-1-0]
              isSelected: _activeNoteId == note.id,
              onTap: () {
                setState(() {
                  // 이미 선택된 걸 다시 누르면 닫고, 아니면 해당 ID를 활성화 [cite: 1-1-0]
                  _activeNoteId = note.id;
                });
              },
              onRefresh: refresh,
            );
          },
        );
      },
    );
  }
}

// 개별 아이템의 클릭 상태를 관리하기 위한 내부 위젯 [cite: 1-1-0]
class _GalleryTile extends StatefulWidget {
  final Note note;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback onRefresh;

  const _GalleryTile({
    required this.note,
    required this.isSelected,
    required this.onTap,
    required this.onRefresh
  });

  @override
  State<_GalleryTile> createState() => _GalleryTileState();
}

class _GalleryTileState extends State<_GalleryTile> {
  // bool _showInfo = false; // 정보 표시 여부 상태 [cite: 1-1-0]

  @override
  Widget build(BuildContext context) {
    final scale = ( MediaQuery.of(context).size.width/ AppSpacing.designWidth ).clamp(0.3, 1.2);

    return GestureDetector(
      // 1. 한번 클릭: 정보 오버레이 토글 [cite: 1-1-0]
      onTap: () {
        if (widget.isSelected) {
          // [변경] 이미 선택된 상태에서 또 클릭하면 상세 모달 오픈 [cite: 1-1-0]
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (context) => NoteDetailsModal(note: widget.note),
          ).then((result) {
            if (result == true) widget.onRefresh();
          });
        } else {
          // 선택되지 않은 상태라면 부모에게 나를 선택해달라고 알림
          widget.onTap();
        }
      },

      child: Stack(
        fit: StackFit.expand,
        children: [
          // 기본 레이어: 사진 [cite: 1-1-0]
          Image.file(
            File(widget.note.image!),
            fit: BoxFit.cover,
          ),

          // 오버레이 레이어: 검정 배경에 정보 표시 (토글 시에만 등장) [cite: 1-1-0]
          if (widget.isSelected)
            Container(
              color: Colors.black.withOpacity(0.7), // 짙은 검정 오버레이 [cite: 1-1-0]
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                // 메뉴명, 맛 정보, 카페명, 마신 날짜 정보 나열
                  Text(
                    widget.note.menu,
                    textAlign: TextAlign.start,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 25),
                  ),
                  const SizedBox(height: 15),

                  // 2. 맛 정보 (산미, 바디, 쓴맛 막대 바) [cite: 1-1-0]
                  buildLevelDisplay("산미", widget.note.levelAcidity, scale * 1.5, Colors.white),
                  const SizedBox(height: 4),
                  buildLevelDisplay("바디", widget.note.levelBody, scale * 1.5, Colors.white),
                  const SizedBox(height: 4),
                  buildLevelDisplay("쓴맛", widget.note.levelBitterness, scale * 1.5, Colors.white),

                  const Spacer(),

                  // 3. 카페명
                  Row(
                    children: [
                      const Icon(Icons.location_on, size: 15, color: Colors.white70),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          widget.note.location,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(color: Colors.white70, fontSize: 15),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),

                  // 4. drankAt (날짜) [cite: 1-1-0]
                  Row(
                    children: [
                      const Icon(Icons.calendar_today, size: 15, color: Colors.white70),
                      const SizedBox(width: 4),
                      Text(
                        widget.note.drankAt.toString().split(' ')[0], // YYYY-MM-DD 형식
                        style: const TextStyle(color: Colors.white70, fontSize: 15),
                      ),
                    ],
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
