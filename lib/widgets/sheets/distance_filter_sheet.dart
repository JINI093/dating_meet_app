import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:geolocator/geolocator.dart';

import '../../utils/app_colors.dart';
import '../../utils/app_text_styles.dart';
import '../../utils/app_dimensions.dart';
import '../../services/location_service.dart';

class DistanceFilterSheet extends StatefulWidget {
  final double? currentDistance;

  const DistanceFilterSheet({
    super.key,
    this.currentDistance,
  });

  @override
  State<DistanceFilterSheet> createState() => _DistanceFilterSheetState();
}

class _DistanceFilterSheetState extends State<DistanceFilterSheet> {
  double _currentDistance = 15.0; // 기본값 15km
  bool _isLocationEnabled = false;
  bool _isCheckingLocation = false;
  Position? _userPosition;

  @override
  void initState() {
    super.initState();
    if (widget.currentDistance != null) {
      _currentDistance = widget.currentDistance!;
    }
    _checkLocationStatus();
  }

  Future<void> _checkLocationStatus() async {
    setState(() {
      _isCheckingLocation = true;
    });

    try {
      final locationService = LocationService();
      final position = await locationService.getCurrentLocation();
      
      setState(() {
        _userPosition = position;
        _isLocationEnabled = true;
        _isCheckingLocation = false;
      });
    } catch (e) {
      setState(() {
        _isLocationEnabled = false;
        _isCheckingLocation = false;
      });
    }
  }

  Future<void> _enableLocation() async {
    setState(() {
      _isCheckingLocation = true;
    });

    try {
      final locationService = LocationService();
      final position = await locationService.getCurrentLocation();
      
      setState(() {
        _userPosition = position;
        _isLocationEnabled = true;
        _isCheckingLocation = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('위치 설정이 완료되었습니다.'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isLocationEnabled = false;
        _isCheckingLocation = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('위치 설정에 실패했습니다: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          
          // Header
          Container(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                const Text(
                  '내 주변 거리 설정',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const Icon(
                    CupertinoIcons.xmark,
                    color: Colors.grey,
                    size: 24,
                  ),
                ),
              ],
            ),
          ),
          
          // Distance Display and Slider
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                // Distance Display
                Text(
                  '${_currentDistance.round()}km',
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                  ),
                ),
                
                const SizedBox(height: 30),
                
                // Slider
                SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    activeTrackColor: const Color(0xFFE91E63),
                    inactiveTrackColor: Colors.grey[300],
                    thumbColor: const Color(0xFFE91E63),
                    thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 12),
                    overlayColor: const Color(0xFFE91E63).withValues(alpha: 0.1),
                    trackHeight: 6,
                  ),
                  child: Slider(
                    value: _currentDistance,
                    min: 1,
                    max: 100,
                    onChanged: (value) {
                      setState(() {
                        _currentDistance = value;
                      });
                    },
                  ),
                ),
                
                const SizedBox(height: 30),
                
                // Location Status
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Column(
                    children: [
                      if (_isCheckingLocation)
                        const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Color(0xFFE91E63),
                              ),
                            ),
                            SizedBox(width: 8),
                            Text(
                              '위치 확인 중...',
                              style: TextStyle(
                                fontSize: 14,
                                color: Color(0xFFE91E63),
                              ),
                            ),
                          ],
                        )
                      else if (_isLocationEnabled)
                        const Text(
                          '설정 내 GPS 입력을 확인해주세요.',
                          style: TextStyle(
                            fontSize: 14,
                            color: Color(0xFFE91E63),
                            fontWeight: FontWeight.w500,
                          ),
                        )
                      else
                        GestureDetector(
                          onTap: _enableLocation,
                          child: const Text(
                            '설정 내 GPS 입력을 확인해주세요.',
                            style: TextStyle(
                              fontSize: 14,
                              color: Color(0xFFE91E63),
                              fontWeight: FontWeight.w500,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      
                      const SizedBox(height: 8),
                      
                      Text(
                        _isLocationEnabled
                            ? '범위 내 프로필이 없을 시 거리 범위를 자동으로 조정합니다.'
                            : '범위 내 프로필이 없을 시 거리 범위를 자동으로 조정합니다.',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // Apply Button
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            child: SizedBox(
              height: 56,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context, {
                    'distance': _currentDistance,
                    'position': _userPosition,
                    'isLocationEnabled': _isLocationEnabled,
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2D2D2D),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  '설정',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}