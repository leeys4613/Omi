
// import 'package:flutter/material.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:location/location.dart';
// import 'dart:math';
// import 'package:flutter/services.dart' show rootBundle;

// class MapScreen extends StatefulWidget {
//   const MapScreen({super.key});

//   @override
//   MapScreenState createState() => MapScreenState();
// }

// class MapScreenState extends State<MapScreen> {
//   late GoogleMapController _mapController;
//   final LatLng _defaultPosition = const LatLng(37.5665, 126.9780); // 초기 위치 (서울)
//   LatLng? _currentLocation; // 현재 위치 저장
//   final Set<Marker> _markers = {}; // 개별 마커
//   final Set<Marker> _clusterMarkers = {}; // 클러스터 마커
//   final List<LatLng> _omiLocations = []; // Omi 위치
//   final List<LatLng> _missionLocations = []; // Mission 위치
//   final List<LatLng> _recordLocations = []; // Record 위치
//   double _currentZoom = 16.5; // 초기 줌 레벨
//   String? _mapStyle; // 사용자 정의 지도 스타일
//   final Map<String, bool> _markerVisibility = {
//     'omi': false,
//     'mission': false,
//     'record': false,
//   }; // 버튼 상태

//   @override
//   void initState() {
//     super.initState();
//     _loadMapStyle(); // 사용자 정의 지도 스타일 로드
//     _checkLocationPermission(); // 위치 권한 확인 및 현재 위치 가져오기
//     _generateRandomLocations(100, _omiLocations); // 100마리 Omi
//     _generateRandomLocations(50, _missionLocations); // 50개 Mission
//     _generateRandomLocations(30, _recordLocations); // 30개 Record
//   }

//   // 지도 스타일 로드
//   Future<void> _loadMapStyle() async {
//     _mapStyle = await rootBundle.loadString('assets/map_style.json');
//   }

//   // 위치 권한 확인 및 현재 위치 가져오기
//   Future<void> _checkLocationPermission() async {
//     final Location location = Location();

//     bool serviceEnabled = await location.serviceEnabled();
//     if (!serviceEnabled) {
//       serviceEnabled = await location.requestService();
//       if (!serviceEnabled) return;
//     }

//     PermissionStatus permissionGranted = await location.hasPermission();
//     if (permissionGranted == PermissionStatus.denied) {
//       permissionGranted = await location.requestPermission();
//       if (permissionGranted != PermissionStatus.granted) return;
//     }

//     final LocationData locationData = await location.getLocation();
//     setState(() {
//       _currentLocation = LatLng(
//         locationData.latitude ?? _defaultPosition.latitude,
//         locationData.longitude ?? _defaultPosition.longitude,
//       );
//     });
//   }

//   // 랜덤 위치 생성
//   void _generateRandomLocations(int count, List<LatLng> locations) {
//     final Random random = Random();
//     for (int i = 0; i < count; i++) {
//       final double lat =
//           _defaultPosition.latitude + (random.nextDouble() - 0.5) * 0.05;
//       final double lng =
//           _defaultPosition.longitude + (random.nextDouble() - 0.5) * 0.05;
//       locations.add(LatLng(lat, lng));
//     }
//   }

//   // 현재 뷰포트(화면에 보이는 영역) 가져오기
//   Future<LatLngBounds> _getVisibleBounds() async {
//     return await _mapController.getVisibleRegion();
//   }

//   // 뷰포트 내의 마커 필터링
//   List<LatLng> _getMarkersInViewport(
//       List<LatLng> locations, LatLngBounds bounds) {
//     return locations.where((location) {
//       return (location.latitude >= bounds.southwest.latitude &&
//               location.latitude <= bounds.northeast.latitude) &&
//           (location.longitude >= bounds.southwest.longitude &&
//               location.longitude <= bounds.northeast.longitude);
//     }).toList();
//   }

//   // 마커 및 클러스터 업데이트
//   Future<void> _updateMarkersAndClusters() async {
//     final LatLngBounds bounds = await _getVisibleBounds();

//     setState(() {
//       _markers.clear();
//       _clusterMarkers.clear();

//       // 모든 활성화된 마커를 클러스터링
//       if (_markerVisibility['omi']!) {
//         _createClusters(_getMarkersInViewport(_omiLocations, bounds),
//             BitmapDescriptor.hueRose);
//       }
//       if (_markerVisibility['mission']!) {
//         _createClusters(_getMarkersInViewport(_missionLocations, bounds),
//             BitmapDescriptor.hueAzure);
//       }
//       if (_markerVisibility['record']!) {
//         _createClusters(_getMarkersInViewport(_recordLocations, bounds),
//             BitmapDescriptor.hueGreen);
//       }
//     });
//   }

//   // 클러스터 생성
//   void _createClusters(List<LatLng> visibleLocations, double hue) {
//     const double clusterRadius = 0.02; // 2km 반경
//     final Map<LatLng, List<LatLng>> clusters = {};

//     for (final location in visibleLocations) {
//       LatLng? clusterKey;

//       for (final clusterCenter in clusters.keys) {
//         if (_calculateDistance(location, clusterCenter) < clusterRadius) {
//           clusterKey = clusterCenter;
//           break;
//         }
//       }

//       if (clusterKey != null) {
//         clusters[clusterKey]!.add(location);
//       } else {
//         clusters[location] = [location];
//       }
//     }

//     // 클러스터 아이콘 생성
//     clusters.forEach((center, points) {
//       if (points.length > 1) {
//         _clusterMarkers.add(Marker(
//           markerId: MarkerId(center.toString()),
//           position: center,
//           icon: BitmapDescriptor.defaultMarkerWithHue(hue),
//         ));
//       } else {
//         _markers.add(Marker(
//           markerId: MarkerId(center.toString()),
//           position: center,
//           icon: BitmapDescriptor.defaultMarkerWithHue(hue),
//         ));
//       }
//     });
//   }

//   // 거리 계산
//   double _calculateDistance(LatLng a, LatLng b) {
//     const double earthRadius = 6371;
//     final double dLat = _degreesToRadians(b.latitude - a.latitude);
//     final double dLng = _degreesToRadians(b.longitude - a.longitude);
//     final double lat1 = _degreesToRadians(a.latitude);
//     final double lat2 = _degreesToRadians(b.latitude);

//     final double aHarv =
//         pow(sin(dLat / 2), 2) + cos(lat1) * cos(lat2) * pow(sin(dLng / 2), 2);
//     return earthRadius * 2 * atan2(sqrt(aHarv), sqrt(1 - aHarv));
//   }

//   double _degreesToRadians(double degrees) => degrees * pi / 180;

//   // 버튼 클릭 시 마커 활성화/비활성화
//   void _toggleMarkerVisibility(String type) {
//     setState(() {
//       _markerVisibility[type] = !_markerVisibility[type]!;
//       _updateMarkersAndClusters();
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Stack(
//         children: [
//           GoogleMap(
//             style: _mapStyle,
//             initialCameraPosition: CameraPosition(
//               target: _currentLocation ?? _defaultPosition,
//               zoom: _currentZoom,
//             ),
//             onMapCreated: (controller) {
//               _mapController = controller;
//               _updateMarkersAndClusters();
//             },
//             myLocationEnabled: true, // 파란 점 활성화
//             myLocationButtonEnabled: true, // 위치 버튼 활성화
//             onCameraMove: (CameraPosition position) {
//               _currentZoom = position.zoom;
//               _updateMarkersAndClusters();
//             },
//             markers: {..._markers, ..._clusterMarkers},
//           ),
//           Positioned(
//             top: 50,
//             left: 20,
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//               children: [
//                 _buildToggleButton('omi', 'Omi', const Color(0xFFE91E63)),
//                 const SizedBox(width: 15),
//                 _buildToggleButton('mission', '미션', const Color(0xFF03A9F4)),
//                 const SizedBox(width: 15),
//                 _buildToggleButton('record', '기록', const Color(0xFF4CAF50)),
//               ],
//             ),
//           ),
//           Positioned(
//             bottom: 20,
//             left: 20,
//             child: FloatingActionButton(
//               onPressed: () {
//                 _mapController.animateCamera(
//                   CameraUpdate.newCameraPosition(
//                     CameraPosition(
//                       target: _currentLocation ?? _defaultPosition,
//                       zoom: 16.5,
//                     ),
//                   ),
//                 );
//               },
//               backgroundColor: Colors.white,
//               child: const Icon(Icons.my_location, color: Colors.black),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   // 버튼 위젯 생성
//   Widget _buildToggleButton(String type, String label, Color color) {
//     return ElevatedButton(
//       onPressed: () => _toggleMarkerVisibility(type),
//       style: ElevatedButton.styleFrom(
//         backgroundColor: _markerVisibility[type]! ? color : Colors.grey,
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
//       ),
//       child: Text(label, style: const TextStyle(color: Colors.white)),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:math';
import 'package:flutter/services.dart' show rootBundle;

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  MapScreenState createState() => MapScreenState();
}

class MapScreenState extends State<MapScreen> {
  GoogleMapController? _mapController;
  final LatLng _defaultPosition = const LatLng(37.3786, 127.1148); // 초기 위치
  final LatLng _currentLocation = const LatLng(37.3786, 127.1148); // 초기 위치 설정
  double _currentZoom = 16.5;

  final Set<Marker> _markers = {}; // 개별 마커
  final Set<Marker> _clusterMarkers = {}; // 클러스터 마커

  final Map<String, List<LatLng>> _markersByType = {
    'omi': [],
    'mission': [],
    'record': [],
  };

  final Map<String, bool> _markerVisibility = {
    'omi': true,
    'mission': false,
    'record': false,
  };

  @override
  void initState() {
    super.initState();
    _generateRandomMarkers('omi', 100); // Omi 100마리 방생
    _loadMapStyle();
    _updateMarkersAndClusters();
  }

  Future<void> _loadMapStyle() async {
    String mapStyle = await rootBundle.loadString('assets/map_style.json');
    if (_mapController != null) {
      _mapController!.setMapStyle(mapStyle);
    }
  }

  void _generateRandomMarkers(String type, int count) {
    final Random random = Random();
    for (int i = 0; i < count; i++) {
      final LatLng randomLocation = LatLng(
        _defaultPosition.latitude + (random.nextDouble() - 0.5) * 0.05,
        _defaultPosition.longitude + (random.nextDouble() - 0.5) * 0.05,
      );
      _markersByType[type]?.add(randomLocation);
    }
  }

  Future<void> _updateMarkersAndClusters() async {
    setState(() {
      _markers.clear();
      _clusterMarkers.clear();

      for (String type in _markerVisibility.keys) {
        if (_markerVisibility[type]!) {
          for (LatLng location in _markersByType[type]!) {
            _markers.add(
              Marker(
                markerId: MarkerId(location.toString()),
                position: location,
                icon:
                    BitmapDescriptor.defaultMarkerWithHue(_getMarkerHue(type)),
              ),
            );
          }
        }
      }
    });
  }

  double _getMarkerHue(String type) {
    switch (type) {
      case 'omi':
        return BitmapDescriptor.hueRose;
      case 'mission':
        return BitmapDescriptor.hueAzure;
      case 'record':
        return BitmapDescriptor.hueGreen;
      default:
        return BitmapDescriptor.hueOrange;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: _currentLocation,
              zoom: _currentZoom,
            ),
            onMapCreated: (GoogleMapController controller) {
              _mapController = controller;
              _loadMapStyle();
            },
            onCameraMove: (CameraPosition position) {
              setState(() {
                _currentZoom = position.zoom;
              });
            },
            onCameraIdle: _updateMarkersAndClusters,
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            markers: _markers,
          ),
          Positioned(
            top: 50,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildToggleButton('omi', 'Omi', const Color(0xFFE91E63)),
                //const SizedBox(width: 15),
                _buildToggleButton('mission', '미션', const Color(0xFF03A9F4)),
                //const SizedBox(width: 15),
                _buildToggleButton('record', '기록', const Color(0xFF4CAF50)),
              ],
            ),
          ),
          Positioned(
            bottom: 20,
            left: 20,
            child: FloatingActionButton(
              onPressed: () {
                if (_mapController != null) {
                  _mapController!.animateCamera(
                    CameraUpdate.newCameraPosition(
                      CameraPosition(
                        target: _defaultPosition,
                        zoom: 16.5,
                      ),
                    ),
                  );
                }
              },
              backgroundColor: Colors.white,
              child: const Icon(Icons.my_location, color: Colors.black),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToggleButton(String type, String label, Color color) {
    return ElevatedButton(
      onPressed: () {
        setState(() {
          _markerVisibility[type] = !_markerVisibility[type]!;
          _updateMarkersAndClusters();
        });
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: _markerVisibility[type]! ? color : Colors.grey,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      child: Text(label, style: const TextStyle(color: Colors.white)),
    );
  }
}