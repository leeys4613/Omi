import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'nurture_screen.dart';
import 'map_screen.dart';
import 'ar_screen.dart';

final GlobalKey<HomeScreenState> globalHomeScreenKey =
    GlobalKey<HomeScreenState>();

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  MainScreenState createState() => MainScreenState();
}

class MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    HomeScreen(key: globalHomeScreenKey),
    const NurtureScreen(),
    const MapScreen(),
    const ARScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
        canvasColor: const Color.fromARGB(255, 255, 255, 255), // 하단 바 배경색 설정
      ),
      child: Scaffold(
        body: IndexedStack(
          index: _currentIndex,
          children: _screens,
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _currentIndex, // 현재 선택된 인덱스
          selectedItemColor: const Color.fromARGB(255, 96, 125, 139), // 선택된 버튼 색상
          unselectedItemColor:
              const Color.fromARGB(255, 144, 164, 174), // 선택되지 않은 버튼 색상
          onTap: (index) {
            setState(() {
              if (_currentIndex != 0 && index == 0) {
                globalHomeScreenKey.currentState?.restartAnimation();
              }
              _currentIndex = index;
            });
          },
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: '홈',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.pets),
              label: '양육',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.map),
              label: '지도',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.camera),
              label: 'AR',
            ),
          ],
        ),
      ),
    );
  }
}
