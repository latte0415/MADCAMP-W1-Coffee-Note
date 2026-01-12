import 'package:flutter/material.dart';
import 'pages/list_page.dart';
import 'pages/modals/creation_modal.dart';
import 'pages/gallery_page.dart';
import 'pages/ai_guide_page.dart';
import 'theme/app_colors.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {

  int _selectedIndex = 0;

  // creation 후 새로고침을 위한 global 선언
  final GlobalKey<ListPageState> _listPageKey = GlobalKey<ListPageState>();
  final GlobalKey<GalleryPageState> _galleryPageKey = GlobalKey<GalleryPageState>();

  // 각 인덱스에 맞는 화면 리스트
  List<Widget> get _pages => [
    ListPage(key: _listPageKey),
    GalleryPage(key: _galleryPageKey),
    const AiGuidePage(),
  ];

  // 탭을 클릭할 때 실행될 함수
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],

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
            ).then((_) {
              // [핵심] 팝업이 닫히면 ListPage 내부의 함수를 강제로 실행시킵니다. (새로고침)
              _listPageKey.currentState?.refreshNotes();
            });
          },
          backgroundColor: AppColors.primaryDark,
          tooltip: 'Add Note',
          child: const Icon(Icons.add, color: AppColors.background),
        ),
      );
  }
}