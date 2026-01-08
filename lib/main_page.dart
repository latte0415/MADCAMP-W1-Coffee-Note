import 'package:flutter/material.dart';
import 'pages/list_page.dart';
// import 'pages/gallery_page.dart';
// import 'pages/recommendation_page.dart';

class MainPage extends StatefulWidget { // [수정] 이름을 MainPage로 변경
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _selectedIndex = 0;

  // [추가] 각 인덱스에 맞는 화면 리스트
  List<Widget> get _pages => [
    const ListPage(),
    const Center(child: Text('2-0-0 GALLERY 화면')),
    const Center(child: Text('3-0-0 RECOMMENDATION 화면')),
  ];

  // [추가] 탭을 클릭할 때 실행될 함수
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('COFFEE NOTE'),
          centerTitle: true,
          // 탭 버튼들 (상단 네비게이션 바 역할)
          // bottom: const TabBar(
          //   tabs: [
          //     Tab(icon: Icon(Icons.list_alt), text: 'LIST'),
          //     Tab(icon: Icon(Icons.grid_view), text: 'GALLERY'),
          //     Tab(icon: Icon(Icons.auto_awesome), text: 'RECO'),
          //   ],
          // ),
        ),
        // [변경] TabBarView 대신, 선택된 인덱스의 페이지를 보여줍니다.
        body: _pages[_selectedIndex],

        // [추가] 화면 아래에 네비게이션 바를 배치합니다.
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _selectedIndex, // 현재 눌린 버튼 표시
          onTap: _onItemTapped,         // 클릭 시 인덱스 변경 함수 호출
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.list_alt), label: 'LIST'),
            BottomNavigationBarItem(icon: Icon(Icons.grid_view), label: 'GALLERY'),
            BottomNavigationBarItem(icon: Icon(Icons.auto_awesome), label: 'RECO'),
          ],
        ),

        // 공통 추가 버튼 (1-1-0 기능으로 연결 예정)
        floatingActionButton: FloatingActionButton(
          onPressed: () {}, // 지금은 숫자가 올라가지만, 나중에 노트 추가로 바꿀 거예요!
          tooltip: 'Add Note',
          child: const Icon(Icons.add),
        ),
      );
  }
}