import 'dart:io';
import 'package:flutter/material.dart';
import '../models/note.dart';
import '../models/sort_option.dart';
import '../services/note_service.dart';
import '../pages/modals/details_modal.dart';

class GalleryPage extends StatefulWidget {
  const GalleryPage({super.key});

  @override
  State<GalleryPage> createState() => GalleryPageState();
}

class GalleryPageState extends State<GalleryPage> {
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
          padding: const EdgeInsets.all(8),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 1,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
            childAspectRatio: 1, // 세로로 약간 긴 형태
          ),
          itemCount: notesWithImage.length,
          itemBuilder: (context, index) {
            final note = notesWithImage[index];
            return _buildGalleryItem(note);
          },
        );
      },
    );
  }

  Widget _buildGalleryItem(Note note) {
    return GestureDetector(
      // 클릭 시 상세 모달 표시 및 새로고침 로직
      onTap: () {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (context) => NoteDetailsModal(note: note),
        ).then((result) {
          if (result == true) {
            refresh(); // 수정 저장 후 돌아오면 갤러리 갱신
          }
        });
      },
      child: Card(
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 2,
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 1. 이미지 영역
                Expanded(
                  child: note.image != null && note.image!.isNotEmpty
                      ? Image.file(
                    File(note.image!),
                    fit: BoxFit.cover,
                  )
                      : Container(
                    color: Colors.grey[100],
                    child: const Icon(Icons.coffee, color: Colors.grey, size: 40),
                  ),
                ),

                // 2. 텍스트 및 상세 정보 영역
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text(
                        note.comment.isEmpty ? "한줄평을 작성하지 않았어요 :(" : note.comment,
                        maxLines: 1, // 갤러리는 공간이 좁아 1줄 권장 [cite: 1-1-0]
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            // 3. 우측 상단 점수 레이블
            Positioned(
              top: 8,
              right: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.star, color: Colors.amber, size: 15),
                    const SizedBox(width: 2),
                    Text(
                      '${note.score}',
                      style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}