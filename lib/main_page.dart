import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'features/library/presentation/pages/library_page.dart';
import 'features/gallery/presentation/pages/gallery_page.dart';
import 'features/ai_guide/presentation/pages/ai_guide_page.dart';
import 'shared/presentation/modals/creation_modal.dart';
import 'theme/theme.dart';
import 'features/library/controller/library_controller.dart';
import 'features/gallery/controller/gallery_controller.dart';
import 'backend/providers.dart';

class MainPage extends ConsumerStatefulWidget {
  const MainPage({super.key});

  @override
  ConsumerState<MainPage> createState() => _MainPageState();
}

class _MainPageState extends ConsumerState<MainPage> {

  int _selectedIndex = 0;

  // 탭을 클릭할 때 실행될 함수
  void _onItemTapped(int index) {
    // 같은 탭을 다시 클릭한 경우 리프레시하지 않음
    if (_selectedIndex == index) {
      return;
    }

    setState(() {
      _selectedIndex = index;
    });

    // 라이브러리 탭으로 이동 시 리프레시
    if (index == 0) {
      ref.read(libraryControllerProvider.notifier).refresh();
    }
    // 갤러리 탭으로 이동 시 리프레시
    else if (index == 1) {
      ref.read(galleryControllerProvider.notifier).refresh();
    }
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      const LibraryPage(),
      const GalleryPage(),
      const AiGuidePage(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(""),
        backgroundColor: Colors.white, // 배경색
        elevation: 0,                 // 그림자 제거해서 깔끔하게 padding 느낌만 주기
        centerTitle: false,           // 좌측 정렬 (원하시면 true로 변경)
        toolbarHeight: 10,            // AppBar의 높이 조절 (패딩 느낌 조절)
      ),

      body: pages[_selectedIndex],

        // 탭 선택: 화면 아래에 네비게이션 바를 배치합니다.
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _selectedIndex, // 현재 눌린 버튼 표시
          onTap: _onItemTapped,         // 클릭 시 인덱스 변경 함수 호출
          selectedItemColor: AppColors.primaryDark,
          unselectedItemColor: Colors.grey,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.list_alt), label: '라이브러리'),
            BottomNavigationBarItem(icon: Icon(Icons.grid_view), label: '갤러리'),
            BottomNavigationBarItem(icon: Icon(Icons.auto_awesome), label: 'AI 가이드'),
          ],
        ),

        // (+) 노트 추가 버튼 (creation으로 연결)
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            showDialog(
              context: context,
              // isScrollControlled: true, // 키보드 가림 방지 및 높이 조절
              // constraints: BoxConstraints(
              //   maxHeight: MediaQuery.of(context).size.height * 0.8,
              // ),
              // shape: const RoundedRectangleBorder(
              //   borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
              // ),
              builder: (context) => const NoteCreatePopup(),
            ).then((result) {
              // 노트 생성 성공 시 library와 gallery 모두 refresh
              if (result == true) {
                ref.read(libraryControllerProvider.notifier).refresh();
                ref.read(galleryControllerProvider.notifier).refresh();
              }
            });
          },
          backgroundColor: AppColors.primaryDark,
          tooltip: 'Add Note',
          child: const Icon(Icons.add, color: AppColors.background),
        ),
      );
  }
}