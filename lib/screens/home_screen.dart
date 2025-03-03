import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';
import 'status_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  // 애니메이션 컨트롤러 및 상태값
  late AnimationController _animationController;
  late Map<String, Animation<double>> _gaugeAnimations;

  // 이벤트 데이터
  final List<Map<String, dynamic>> _eventData = [
    {
      'title': '오늘의 이벤트',
      'description': '오늘 참여하고 특별 보상을 받아보세요!',
      'icon': Icons.local_fire_department,
    },
    {
      'title': '주간 이벤트',
      'description': '이번 주 한정 혜택, 지금 바로 확인하세요!',
      'icon': Icons.calendar_today,
    },
    {
      'title': '월간 이벤트',
      'description': '한 달 동안의 특별한 혜택을 만나보세요.',
      'icon': Icons.star,
    },
  ];

  // 상태 링 데이터
  final Map<String, double> _statusValues = {
    '공복': 70,
    '체력': 50,
    '행복': 90,
  };
  final Map<String, String> _statusTexts = {
    '공복': '든든해요',
    '체력': '7,000보',
    '행복': '(수면) 3시간\n(웃음) 4초',
  };
  final Map<String, Color> _statusColors = {
    '공복': Colors.deepOrangeAccent,
    '체력': Colors.green,
    '행복': Colors.blue,
  };

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    // 애니메이션 컨트롤러 초기화
    _animationController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );

    // 애니메이션 초기화 및 시작
    _initializeAnimations();
    _restartAnimation();
  }

  void _initializeAnimations() {
    // 상태 링의 애니메이션 설정
    _gaugeAnimations = _statusValues.map((key, value) {
      return MapEntry(
        key,
        Tween<double>(begin: 0, end: value).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Curves.easeOut,
          ),
        ),
      );
    });
  }

  void _restartAnimation() {
    // 애니메이션 리셋 후 실행
    _animationController.reset();
    _animationController.forward();
  }

  void restartAnimation() {
    _restartAnimation();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // 앱 재활성화 시 애니메이션 재시작
    if (state == AppLifecycleState.resumed &&
        ModalRoute.of(context)?.isCurrent == true) {
      _restartAnimation();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _animationController.dispose();
    super.dispose();
  }

  // 상단 네트워크 탭 UI
  Widget _buildNetworkTabs() {
    return Container(
      color: const Color.fromARGB(255, 255, 255, 255),
      padding: const EdgeInsets.symmetric(vertical: 8), // 위아래 여백 추가
      child: const DefaultTabController(
        length: 3,
        child: Column(
          children: [
            TabBar(
              labelColor: Color.fromARGB(255, 96, 125, 139), // 선택된 탭 텍스트 색상
              unselectedLabelColor:
                  Color.fromARGB(255, 144, 164, 174), // 선택되지 않은 텍스트 색상
              indicatorColor: Color.fromARGB(255, 144, 164, 174), // 탭 하단 강조선 색상
              tabs: [
                Tab(icon: Icon(Icons.person), text: '내 프로필'),
                Tab(icon: Icon(Icons.group), text: '친구 목록'),
                Tab(icon: Icon(Icons.feed), text: '활동 피드'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // 이벤트 캐러셀 UI
  Widget _buildEventCarousel() {
    return Positioned(
      bottom: 20,
      left: 15,
      right: 15,
      child: SizedBox(
        height: 150,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: _eventData.length,
          itemBuilder: (context, index) {
            final event = _eventData[index];
            return _buildEventCard(event);
          },
        ),
      ),
    );
  }

  // 각 이벤트 카드 UI
  Widget _buildEventCard(Map<String, dynamic> event) {
    return Container(
      width: 300,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: const Color.fromARGB(255, 255, 255, 255),
        boxShadow: [
          BoxShadow(
            color: const Color.fromARGB(162, 162, 143, 113).withAlpha(20),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          const SizedBox(width: 10),
          Icon(
            event['icon'],
            size: 50,
            color: const Color.fromARGB(255, 255, 40, 40),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event['title']!,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  event['description']!,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 캐릭터 UI
  Widget _buildCharacter() {
    return Positioned(
      top: 90,
      right: 30,
      child: Image.asset(
        'assets/images/character_omi.png',
        height: 180,
        width: 180,
        fit: BoxFit.fill,
      ),
    );
  }

  // 상태 링 UI
  Widget _buildStatusRing(
      BuildContext context, String status, Animation<double> animation,
      [String? text, Color? color]) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: Row(
        children: [
          SizedBox(
            width: 70,
            height: 70,
            child: AnimatedBuilder(
              animation: animation,
              builder: (context, child) {
                return SfRadialGauge(
                  axes: <RadialAxis>[
                    RadialAxis(
                      showTicks: false,
                      showLabels: false,
                      startAngle: 270,
                      endAngle: 270 + 360,
                      minimum: 0,
                      maximum: 100,
                      axisLineStyle: AxisLineStyle(
                        thickness: 0.13,
                        thicknessUnit: GaugeSizeUnit.factor,
                        color: Colors.grey.shade300,
                      ),
                      pointers: <GaugePointer>[
                        RangePointer(
                          value: animation.value,
                          width: 0.13,
                          sizeUnit: GaugeSizeUnit.factor,
                          color: color ?? Colors.grey,
                          cornerStyle: CornerStyle.bothCurve,
                        ),
                      ],
                      annotations: <GaugeAnnotation>[
                        GaugeAnnotation(
                          widget: Text(
                            '${animation.value.toInt()}%',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: color ?? Colors.grey,
                            ),
                          ),
                          positionFactor: 0.1,
                          angle: 0,
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                text ?? '',
                style: const TextStyle(fontSize: 14),
              ),
              Text(
                status,
                style: TextStyle(fontSize: 16, color: color ?? Colors.grey),
              ),
            ],
          ),
        ],
      ),
    );
  }

// 2D 평균 상태 게이지 (눕혀서 차오르는 효과 유지)
  Widget _buildCombinedAverageGauge() {
    double averageValue = _statusValues.values.reduce((a, b) => a + b) /
        _statusValues.length; // 평균 값 계산

    return Positioned(
      top: 200, // 게이지 상단 위치
      right: 10, // 게이지 오른쪽 위치
      child: SizedBox(
        width: 220, // 게이지 너비
        height: 220, // 게이지 높이
        child: Stack(
          alignment: Alignment.center,
          children: [
            // 그림자 추가: 바닥에 붙어 있는 느낌
            Container(
              width: 220,
              height: 220,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
              ),
            ),
            // 게이지 위젯
            AnimatedBuilder(
              animation: _animationController, // 애니메이션 컨트롤러
              builder: (context, child) {
                return Transform(
                  alignment: Alignment.center, // 회전 기준점 설정
                  transform: Matrix4.identity()
                    ..setEntry(2, 1, 0.001) // 입체감 설정
                    ..rotateX(1.3), // X축 회전 각도
                  child: SfRadialGauge(
                    axes: <RadialAxis>[
                      RadialAxis(
                        minimum: 0, // 게이지 최소값
                        maximum: 100, // 게이지 최대값
                        showTicks: false, // 틱 마커 숨기기
                        showLabels: false, // 라벨 숨기기
                        radiusFactor: 0.9, // 게이지 크기 조정
                        axisLineStyle: AxisLineStyle(
                          thickness: 0.1, // 게이지 축 두께
                          thicknessUnit: GaugeSizeUnit.factor, // 두께 단위
                          color: Colors.grey.shade300, // 기본 축 색상
                        ),
                        pointers: <GaugePointer>[
                          RangePointer(
                            value: _animationController.value *
                                averageValue, // 애니메이션 값 적용
                            width: 0.15,
                            sizeUnit: GaugeSizeUnit.factor,
                            color: Colors.blueAccent, // 게이지 색상
                            cornerStyle: CornerStyle.bothCurve, // 양 끝 곡선 스타일
                          ),
                        ],
                        annotations: <GaugeAnnotation>[
                          GaugeAnnotation(
                            widget: Text(
                              '${(_animationController.value * averageValue).toInt()}%', // 현재 애니메이션 값 표시
                              style: const TextStyle(
                                fontSize: 50,
                                fontWeight: FontWeight.bold,
                                color: Colors.blueAccent,
                              ),
                            ),
                            angle: 180,
                            positionFactor: 0.0, // 중앙에 텍스트 위치
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  // 유저 정보 표시 (좋아요, 캐시)
  Widget _buildUserInfo() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildUserStatus(150, Colors.pink, Icons.favorite), // 좋아요
          _buildUserStatus(1000, Colors.orange, Icons.monetization_on), // 캐시
        ],
      ),
    );
  }

  Widget _buildUserStatus(int value, Color color, IconData icon) {
    return Column(
      children: [
        Icon(icon, size: 20, color: color),
        const SizedBox(height: 5),
        Text(
          '$value',
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('omi 앱'),
        backgroundColor: const Color.fromARGB(255, 255, 255, 255), // 상단바 색상
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {
              // 알림 화면 이동
            },
          ),
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // 검색 화면 이동
            },
          ),
        ],
      ),
      backgroundColor: const Color.fromARGB(255, 248, 248, 245), // 아이보리 배경 색상
      body: Column(
        children: [
          _buildNetworkTabs(), // 네트워크 탭
          _buildUserInfo(), // 유저 정보
          Expanded(
            child: Stack(
              children: [
                _buildCharacter(),
                _buildCombinedAverageGauge(),
                Positioned(
                  left: 15,
                  top: 50,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: _statusValues.keys.map((status) {
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => StatusDetailScreen(
                                status: status,
                                onReturnToHome: _restartAnimation,
                              ),
                            ),
                          );
                        },
                        child: _buildStatusRing(
                          context,
                          status,
                          _gaugeAnimations[status]!,
                          _statusTexts[status],
                          _statusColors[status],
                        ),
                      );
                    }).toList(),
                  ),
                ),
                _buildEventCarousel(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// class BottomNavBar extends StatelessWidget {
//   final int selectedIndex;
//   final Function(int) onDestinationSelected;

//   const BottomNavBar({
//     super.key,
//     required this.selectedIndex,
//     required this.onDestinationSelected,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return BottomNavigationBar(
//       currentIndex: selectedIndex,
//       onTap: onDestinationSelected,
//       backgroundColor: Colors.lightBlueAccent,
//       selectedItemColor: Colors.white,
//       unselectedItemColor: Colors.black54,
//       items: const [
//         BottomNavigationBarItem(
//           icon: Icon(Icons.home),
//           label: '홈',
//         ),
//         BottomNavigationBarItem(
//           icon: Icon(Icons.pets),
//           label: '양육',
//         ),
//         BottomNavigationBarItem(
//           icon: Icon(Icons.map),
//           label: '지도',
//         ),
//         BottomNavigationBarItem(
//           icon: Icon(Icons.camera),
//           label: 'AR',
//         ),
//       ],
//     );
//   }
// }
