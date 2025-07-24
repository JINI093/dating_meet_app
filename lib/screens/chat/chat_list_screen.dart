import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../utils/app_colors.dart';
import '../../providers/chat_provider.dart';
import '../../providers/matches_provider.dart';
import '../../models/match_model.dart';
import '../../models/profile_model.dart';
import '../../models/chat_model.dart';
import '../../models/message_model.dart';
import 'chat_room_screen.dart';

class ChatListScreen extends ConsumerStatefulWidget {
  const ChatListScreen({super.key});

  @override
  ConsumerState<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends ConsumerState<ChatListScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final matchesState = ref.watch(matchesProvider);
    final matches = matchesState.matchesWithMessages;
    final isLoading = matchesState.isLoading;

    // Get real chat rooms from AWS matches
    List<ChatRoom> chatRooms = [];
    Map<String, ProfileModel> profileMap = {};
    
    // Convert matches to chat rooms - only use real AWS data
    for (final match in matches) {
      // In a real implementation, this would get chat rooms from AWSChatService
      // For now, we'll work with the match data we have
      profileMap[match.id] = match.profile;
      
      // Create chat room from match data
      // This would normally be managed by the chat service
      final chatRoom = ChatRoom(
        id: 'chat_${match.id}',
        matchId: match.id,
        participantIds: ['current_user', match.profile.id], // Will be replaced with real user IDs
        lastMessage: match.lastMessage != null ? ChatMessage(
          id: 'msg_${match.id}',
          chatId: 'chat_${match.id}',
          senderId: match.profile.id,
          receiverId: 'current_user',
          content: match.lastMessage!,
          type: ChatMessageType.text,
          timestamp: match.lastMessageTime ?? match.matchedAt,
          status: match.hasUnreadMessages ? ChatMessageStatus.delivered : ChatMessageStatus.read,
        ) : null,
        lastActivity: match.lastMessageTime ?? match.matchedAt,
        unreadCounts: {'current_user': match.unreadCount},
        status: ChatRoomStatus.active,
        createdAt: match.matchedAt,
      );
      chatRooms.add(chatRoom);
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 24),
            const Text(
              '대화 리스트',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: '매칭 된 사람, 메시지를 검색해 주세요',
                  prefixIcon: const Icon(CupertinoIcons.search),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 0),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(32),
                    borderSide: BorderSide.none,
                  ),
                ),
                onChanged: (value) => setState(() {}),
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _buildChatList(chatRooms, profileMap),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChatList(List<ChatRoom> chatRooms, Map<String, ProfileModel> profileMap) {
    if (chatRooms.isEmpty) {
      return const Center(child: Text('채팅방이 없습니다'));
    }
    // 검색 필터 적용
    List filteredRooms = chatRooms;
    if (_searchController.text.isNotEmpty) {
      final query = _searchController.text.toLowerCase();
      filteredRooms = chatRooms.where((room) {
        final profile = profileMap[room.id];
        if (profile == null) return false;
        final name = profile.name.toLowerCase();
        final lastMessage = room.lastMessage?.content.toLowerCase() ?? '';
        return name.contains(query) || lastMessage.contains(query);
      }).toList();
    }
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 0),
      itemCount: filteredRooms.length,
      itemBuilder: (context, index) {
        final chatRoom = filteredRooms[index];
        final profile = profileMap[chatRoom.id];
        if (profile == null) return const SizedBox.shrink();
        return ChatSimpleListItem(
          chatRoom: chatRoom,
          profile: profile,
          onTap: () {
            final match = MatchModel(
              id: chatRoom.matchId,
              profile: profile,
              matchedAt: chatRoom.createdAt,
            );
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ChatRoomScreen(
                  match: match,
                  chatId: chatRoom.id,
                ),
              ),
            );
          },
        );
      },
    );
  }
}

// 심플한 채팅 리스트 아이템 위젯
class ChatSimpleListItem extends StatelessWidget {
  final ChatRoom? chatRoom;
  final MatchModel? match;
  final ProfileModel profile;
  final VoidCallback onTap;
  const ChatSimpleListItem({super.key, this.chatRoom, this.match, required this.profile, required this.onTap});
  @override
  Widget build(BuildContext context) {
    final lastMessage = chatRoom?.lastMessage;
    final String? lastMessageContent = chatRoom != null ? lastMessage?.content : match?.lastMessage;
    final isOnline = profile.isOnline;
    return InkWell(
      onTap: onTap,
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
                    lastMessageContent ?? '채팅을 시작해보세요',
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