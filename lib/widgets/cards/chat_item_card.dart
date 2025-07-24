import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class ChatItemCard extends StatelessWidget {
  final chatRoom;
  final profile;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;
  const ChatItemCard({super.key, required this.chatRoom, required this.profile, required this.onTap, this.onLongPress});
  @override
  Widget build(BuildContext context) {
    final lastMessage = chatRoom.lastMessage;
    final isOnline = profile.isOnline;
    return InkWell(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
        child: Row(
          children: [
            CircleAvatar(
              radius: 28,
              backgroundImage: NetworkImage(profile.profileImages.first),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        profile.name,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      if (isOnline) ...[
                        const SizedBox(width: 6),
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: Colors.green,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    lastMessage?.content ?? '',
                    style: const TextStyle(color: Colors.grey, fontSize: 14),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}