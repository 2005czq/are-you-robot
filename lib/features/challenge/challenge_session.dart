class ChallengeSession {
  const ChallengeSession({this.streak = 0});

  final int streak;

  ChallengeSession copyWith({int? streak}) {
    return ChallengeSession(streak: streak ?? this.streak);
  }
}
