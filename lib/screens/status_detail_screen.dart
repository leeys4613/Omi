import 'package:flutter/material.dart';

class StatusDetailScreen extends StatelessWidget {
  final String status;
  final VoidCallback onReturnToHome;

  const StatusDetailScreen({
    required this.status,
    required this.onReturnToHome,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true, // 뒤로가기가 가능하도록 설정
      onPopInvoked: (dynamic result) {
        if (result == true) {
          onReturnToHome.call(); // 뒤로가기 성공 시 콜백 호출
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('$status 상세화면'),
        ),
        body: Center(
          child: Text(
            '$status의 세부 정보를 여기에 표시합니다.',
            style: const TextStyle(fontSize: 18),
          ),
        ),
      ),
    );
  }
}
