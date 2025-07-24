import 'package:flutter/material.dart';
// import 'package:qr_flutter/qr_flutter.dart';

class CouponQrCode extends StatelessWidget {
  final String data;
  final double size;
  final String? label;

  const CouponQrCode({Key? key, required this.data, this.size = 120, this.label}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // 실제 사용 시: QrImage(
        //   data: data,
        //   version: QrVersions.auto,
        //   size: size,
        //   backgroundColor: Colors.white,
        // ),
        Container(
          width: size,
          height: size,
          color: Colors.grey[300],
          alignment: Alignment.center,
          child: const Icon(Icons.qr_code, size: 64, color: Colors.black38),
        ),
        if (label != null)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(label!, style: Theme.of(context).textTheme.bodySmall),
          ),
      ],
    );
  }
} 