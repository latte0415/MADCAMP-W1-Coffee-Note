import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../models/note.dart';
import '../../../../shared/presentation/modals/details_modal.dart';
import '../../../../theme/theme.dart';
import '../widgets/gallery_widgets.dart';
import '../../controller/gallery_controller.dart';
import '../../../../backend/providers.dart';

class GalleryPage extends ConsumerWidget {
  const GalleryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncState = ref.watch(galleryControllerProvider);
    final controller = ref.read(galleryControllerProvider.notifier);

    final isInitialLoading =
        asyncState.isLoading && asyncState.valueOrNull == null;
    final isRefreshing =
        asyncState.valueOrNull?.isRefreshing ?? false;
    final error = asyncState.valueOrNull?.error;
    final notes = asyncState.valueOrNull?.notes ?? const <Note>[];
    final activeNoteId = asyncState.valueOrNull?.state.activeNoteId;

    if (isInitialLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (notes.isEmpty && error == null) {
      return const Center(
        child: Text(
          "사진이 등록된 커피 노트가 없어요 📸",
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.grey,
            fontSize: 13,
          ),
        ),
      );
    }

    return Column(
      children: [
        // 에러 배너
        if (error != null)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.red[50],
              border: Border.all(color: Colors.red[300]!),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.red, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '에러 발생: $error',
                    style: TextStyle(color: Colors.red[900], fontSize: 14),
                  ),
                ),
              ],
            ),
          ),
        if (isRefreshing)
          Padding(
            padding: const EdgeInsets.only(right: 12, top: 8),
            child: Align(
              alignment: Alignment.centerRight,
              child: SizedBox(
                width: 22,
                height: 22,
                child: const CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          ),
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.all(2),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 2,
              mainAxisSpacing: 2,
              childAspectRatio: 1, // 정사각형
            ),
            itemCount: notes.length,
            itemBuilder: (context, index) {
              final note = notes[index];
              return _GalleryTile(
                note: note,
                // 현재 이 노트의 ID가 활성화된 ID와 같은지 확인 [cite: 1-1-0]
                isSelected: activeNoteId == note.id,
                onSelect: () => controller.setActiveNote(note.id),
                onRefresh: () => controller.refresh(),
              );
            },
          ),
        ),
      ],
    );
  }
}

// 개별 아이템: 활성 여부는 Riverpod 상태(activeNoteId)로 관리
class _GalleryTile extends StatelessWidget {
  final Note note;
  final bool isSelected;
  final VoidCallback onSelect;
  final VoidCallback onRefresh;

  const _GalleryTile({
    required this.note,
    required this.isSelected,
    required this.onSelect,
    required this.onRefresh
  });

  @override
  Widget build(BuildContext context) {
    final scale = ( MediaQuery.of(context).size.width/ AppSpacing.designWidth ).clamp(0.3, 1.2);

    return GestureDetector(
      // 1. 한번 클릭: 정보 오버레이 토글 [cite: 1-1-0]
      onTap: () {
        if (isSelected) {
          // [변경] 이미 선택된 상태에서 또 클릭하면 상세 모달 오픈 [cite: 1-1-0]
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (context) => NoteDetailsModal(note: note),
          ).then((result) {
            if (result == true) onRefresh();
          });
        } else {
          // 선택되지 않은 상태라면 부모에게 선택 요청
          onSelect();
        }
      },

      child: Stack(
        fit: StackFit.expand,
        children: [
          // 기본 레이어: 사진 [cite: 1-1-0]
          Image.file(
            File(note.image!),
            fit: BoxFit.cover,
          ),

          // 오버레이 레이어: 검정 배경에 정보 표시 (토글 시에만 등장) [cite: 1-1-0]
          if (isSelected)
            Container(
              color: Colors.black.withOpacity(0.7), // 짙은 검정 오버레이 [cite: 1-1-0]
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                // 메뉴명, 맛 정보, 카페명, 마신 날짜 정보 나열
                  Text(
                    note.menu,
                    textAlign: TextAlign.start,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),
                  ),
                  const SizedBox(height: 10),

                  // 2. 맛 정보 (산미, 바디, 쓴맛 막대 바) [cite: 1-1-0]
                  buildLevelDisplay("산미", note.levelAcidity, scale * 1.5, Colors.white),
                  const SizedBox(height: 4),
                  buildLevelDisplay("바디", note.levelBody, scale * 1.5, Colors.white),
                  const SizedBox(height: 4),
                  buildLevelDisplay("쓴맛", note.levelBitterness, scale * 1.5, Colors.white),

                  const Spacer(),

                  // 3. 카페명
                  Row(
                    children: [
                      const Icon(Icons.location_on, size: 12, color: Colors.white70),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          note.location,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(color: Colors.white70, fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),

                  // 4. drankAt (날짜) [cite: 1-1-0]
                  Row(
                    children: [
                      const Icon(Icons.calendar_today, size: 12, color: Colors.white70),
                      const SizedBox(width: 4),
                      Text(
                        note.drankAt.toString().split(' ')[0], // YYYY-MM-DD 형식
                        style: const TextStyle(color: Colors.white70, fontSize: 12),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),

                  // 5. score
                  Row(
                    children: [
                      // const Icon(Icons.star, size: 15, color: Colors.white70), // 헤더 아이콘
                      // const SizedBox(width: 4),
                      // 별을 score만큼 나열
                      Row(
                        children: List.generate(5, (index) {
                          return Icon(
                            // index가 score보다 작으면 꽉 찬 별, 크면 빈 별 표시
                            index < note.score ? Icons.star : Icons.star_border,
                            size: 12,
                            color: Colors.white70,
                          );
                        }),
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
