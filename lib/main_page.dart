import 'package:flutter/material.dart';
import 'pages/list_page.dart';
import 'pages/modals/creation_modal.dart';
import 'pages/gallery_page.dart';
import 'pages/recommendation_page.dart';

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
    const Center(child: Text('3-0-0 RECOMMENDATION 화면')),
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
      // 상단바
      appBar: AppBar(
          title: const Text('COFFEE NOTE'),
          centerTitle: true,
        ),

        body: _pages[_selectedIndex],

        // 탭 선택: 화면 아래에 네비게이션 바를 배치합니다.
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _selectedIndex, // 현재 눌린 버튼 표시
          onTap: _onItemTapped,         // 클릭 시 인덱스 변경 함수 호출
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.list_alt), label: 'LIST'),
            BottomNavigationBarItem(icon: Icon(Icons.grid_view), label: 'GALLERY'),
            BottomNavigationBarItem(icon: Icon(Icons.auto_awesome), label: 'RECO'),
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
          backgroundColor: Theme.of(context).primaryColor,
          tooltip: 'Add Note',
          child: const Icon(Icons.add, color: Colors.white),
        ),
      );
  }
}