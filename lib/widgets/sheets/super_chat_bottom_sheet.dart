import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:cached_network_image/cached_network_image.dart';


class SuperChatBottomSheet extends StatefulWidget {
  final String profileImageUrl;
  final String name;
  final int age;
  final String location;
  final void Function(String message)? onSend;

  const SuperChatBottomSheet({
    super.key,
    required this.profileImageUrl,
    required this.name,
    required this.age,
    required this.location,
    this.onSend,
  });

  @override
  State<SuperChatBottomSheet> createState() => _SuperChatBottomSheetState();
}

class _SuperChatBottomSheetState extends State<SuperChatBottomSheet> {
  final TextEditingController _controller = TextEditingController();

  Widget _buildProfileImage() {
    if (widget.profileImageUrl.isEmpty) {
      return Container(
        width: double.infinity,
        height: 200,
        color: Colors.grey[300],
        child: const Icon(
          Icons.person,
          size: 80,
          color: Colors.grey,
        ),
      );
    }

    if (widget.profileImageUrl.startsWith('http')) {
      return CachedNetworkImage(
        imageUrl: widget.profileImageUrl,
        width: double.infinity,
        height: 200,
        fit: BoxFit.cover,
        placeholder: (context, url) => Container(
          width: double.infinity,
          height: 200,
          color: Colors.grey[300],
          child: const Center(
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.grey),
            ),
          ),
        ),
        errorWidget: (context, url, error) => Container(
          width: double.infinity,
          height: 200,
          color: Colors.grey[300],
          child: const Icon(
            Icons.person,
            size: 80,
            color: Colors.grey,
          ),
        ),
      );
    } else {
      return Image.asset(
        widget.profileImageUrl,
        width: double.infinity,
        height: 200,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            width: double.infinity,
            height: 200,
            color: Colors.grey[300],
            child: const Icon(
              Icons.person,
              size: 80,
              color: Colors.grey,
            ),
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 상단 타이틀 & 닫기
            Row(
              children: [
                const Text(
                  '슈퍼챗 전송',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const Icon(CupertinoIcons.xmark, size: 24),
                ),
              ],
            ),
            const SizedBox(height: 20),
            // 프로필 카드
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Stack(
                children: [
                  _buildProfileImage(),
                  Positioned(
                    left: 16,
                    bottom: 16,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 28,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${widget.age}세  |  ${widget.location}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // 메시지 입력
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF5F5F5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: TextField(
                controller: _controller,
                maxLines: 4,
                minLines: 4,
                style: const TextStyle(fontSize: 16),
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.all(16),
                  hintText: '메시지를 입력하여 매칭 확률을 높여보세요!',
                  hintStyle: TextStyle(color: Color(0xFFBDBDBD)),
                ),
              ),
            ),
            const SizedBox(height: 24),
            // 슈퍼챗 전송 버튼
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(32),
                  ),
                  elevation: 0,
                ),
                icon: const Icon(
                  CupertinoIcons.money_dollar_circle_fill,
                  color: Color(0xFFFFC700),
                ),
                label: const Text(
                  '슈퍼챗 전송 (50P)',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                onPressed: () {
                  widget.onSend?.call(_controller.text);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}