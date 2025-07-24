import '../models/profile_model.dart';

enum MatchAction {
  like,
  pass,
  superChat,
}

class MatchResult {
  final bool isMatch;
  final String? matchId;
  final String message;

  const MatchResult({
    required this.isMatch,
    this.matchId,
    required this.message,
  });
}

class MatchService {
  // Singleton pattern
  static final MatchService _instance = MatchService._internal();
  factory MatchService() => _instance;
  MatchService._internal();

  // Store user actions locally (in real app, this would sync with backend)
  final Map<String, List<MatchAction>> _userActions = {};
  final Map<String, String> _superChatMessages = {};

  // Simulate backend API calls
  Future<MatchResult> processLike(ProfileModel profile) async {
    // Simulate API delay
    await Future.delayed(const Duration(milliseconds: 300));

    _userActions[profile.id] = [...(_userActions[profile.id] ?? []), MatchAction.like];

    // Simulate match probability (30% chance for demo)
    final isMatch = DateTime.now().millisecond % 10 < 3;

    if (isMatch) {
      return MatchResult(
        isMatch: true,
        matchId: 'match_${profile.id}_${DateTime.now().millisecondsSinceEpoch}',
        message: '${profile.name}ÿ¸ ‰m»µ»‰! <â',
      );
    } else {
      return const MatchResult(
        isMatch: false,
        message: 'ãDî| Ù»µ»‰.',
      );
    }
  }

  Future<MatchResult> processPass(ProfileModel profile) async {
    // Simulate API delay
    await Future.delayed(const Duration(milliseconds: 200));

    _userActions[profile.id] = [...(_userActions[profile.id] ?? []), MatchAction.pass];

    return const MatchResult(
      isMatch: false,
      message: '(§àµ»‰.',
    );
  }

  Future<MatchResult> processSuperChat(ProfileModel profile, String message) async {
    // Simulate API delay
    await Future.delayed(const Duration(milliseconds: 500));

    _userActions[profile.id] = [...(_userActions[profile.id] ?? []), MatchAction.superChat];
    _superChatMessages[profile.id] = message;

    // Super chat has higher match probability (60% chance for demo)
    final isMatch = DateTime.now().millisecond % 10 < 6;

    if (isMatch) {
      return MatchResult(
        isMatch: true,
        matchId: 'match_${profile.id}_${DateTime.now().millisecondsSinceEpoch}',
        message: '${profile.name}ÿ¸ ‰m»µ»‰! à|Wt Ï»¥î =ù',
      );
    } else {
      return MatchResult(
        isMatch: false,
        message: 'à|WD Ù»µ»‰! ı•D 0‰$Ù8î.',
      );
    }
  }

  // Get user's action history for a profile
  List<MatchAction> getUserActions(String profileId) {
    return _userActions[profileId] ?? [];
  }

  // Check if user has already interacted with this profile
  bool hasUserInteracted(String profileId) {
    return _userActions.containsKey(profileId) && _userActions[profileId]!.isNotEmpty;
  }

  // Get super chat message sent to a profile
  String? getSuperChatMessage(String profileId) {
    return _superChatMessages[profileId];
  }

  // Clear actions (for testing purposes)
  void clearActions() {
    _userActions.clear();
    _superChatMessages.clear();
  }

  // Get match statistics
  Map<String, int> getMatchStatistics() {
    int likes = 0;
    int passes = 0;
    int superChats = 0;
    int matches = 0;

    for (final actions in _userActions.values) {
      for (final action in actions) {
        switch (action) {
          case MatchAction.like:
            likes++;
            break;
          case MatchAction.pass:
            passes++;
            break;
          case MatchAction.superChat:
            superChats++;
            break;
        }
      }
    }

    // For demo purposes, assume 25% of likes result in matches
    matches = (likes * 0.25).round() + (superChats * 0.6).round();

    return {
      'likes': likes,
      'passes': passes,
      'superChats': superChats,
      'matches': matches,
      'totalActions': likes + passes + superChats,
    };
  }

  // Simulate getting profiles that matched back
  Future<List<ProfileModel>> getMatches() async {
    await Future.delayed(const Duration(milliseconds: 500));
    
    // Return some mock matches for demo
    final allProfiles = ProfileModel.getMockProfiles();
    final stats = getMatchStatistics();
    final matchCount = stats['matches'] ?? 0;
    
    if (matchCount > 0) {
      return allProfiles.take(matchCount).toList();
    }
    
    return [];
  }

  // Simulate real-time match notifications
  Stream<MatchResult> getMatchStream() async* {
    // In a real app, this would be a WebSocket or Firebase stream
    while (true) {
      await Future.delayed(const Duration(minutes: 5));
      
      // Simulate random incoming matches
      if (DateTime.now().minute % 7 == 0) {
        final profiles = ProfileModel.getMockProfiles();
        final randomProfile = profiles[DateTime.now().second % profiles.length];
        
        yield MatchResult(
          isMatch: true,
          matchId: 'incoming_${randomProfile.id}_${DateTime.now().millisecondsSinceEpoch}',
          message: '${randomProfile.name}ÿt å–ÿD ãDi»‰! =ï',
        );
      }
    }
  }
}