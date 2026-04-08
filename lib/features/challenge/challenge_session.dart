class ChallengeSession {
  const ChallengeSession({
    this.streak = 0,
    this.playedIds = const <String>{},
  });

  final int streak;
  final Set<String> playedIds;

  ChallengeSession copyWith({
    int? streak,
    Set<String>? playedIds,
  }) {
    return ChallengeSession(
      streak: streak ?? this.streak,
      playedIds: playedIds ?? this.playedIds,
    );
  }
}
