import 'dart:convert';

enum ChallengeMode { text, image, video }

extension ChallengeModeX on ChallengeMode {
  String get key => switch (this) {
        ChallengeMode.text => 'text',
        ChallengeMode.image => 'image',
        ChallengeMode.video => 'video',
      };

  String get label => switch (this) {
        ChallengeMode.text => '文字挑战',
        ChallengeMode.image => '图片挑战',
        ChallengeMode.video => '视频挑战',
      };

  static ChallengeMode fromKey(String value) => switch (value) {
        'text' => ChallengeMode.text,
        'image' => ChallengeMode.image,
        'video' => ChallengeMode.video,
        _ => ChallengeMode.text,
      };
}

class ChallengeOption {
  const ChallengeOption({
    required this.id,
    required this.label,
    required this.sourceType,
    this.text,
    this.asset,
    this.credit,
  });

  final String id;
  final String label;
  final String sourceType;
  final String? text;
  final String? asset;
  final String? credit;

  bool get isHuman => sourceType == 'human';

  factory ChallengeOption.fromJson(Map<String, dynamic> json) {
    return ChallengeOption(
      id: json['id'] as String,
      label: json['label'] as String,
      sourceType: json['sourceType'] as String,
      text: json['text'] as String?,
      asset: json['asset'] as String?,
      credit: json['credit'] as String?,
    );
  }
}

class Challenge {
  const Challenge({
    required this.id,
    required this.mode,
    required this.title,
    required this.prompt,
    required this.difficulty,
    required this.explanation,
    required this.options,
  });

  final String id;
  final ChallengeMode mode;
  final String title;
  final String prompt;
  final String difficulty;
  final String explanation;
  final List<ChallengeOption> options;

  factory Challenge.fromJson(Map<String, dynamic> json) {
    return Challenge(
      id: json['id'] as String,
      mode: ChallengeModeX.fromKey(json['mode'] as String),
      title: json['title'] as String,
      prompt: json['prompt'] as String,
      difficulty: json['difficulty'] as String,
      explanation: json['explanation'] as String,
      options: (json['options'] as List<dynamic>)
          .map((option) => ChallengeOption.fromJson(option as Map<String, dynamic>))
          .toList(),
    );
  }

  static List<Challenge> decodeList(String raw) {
    final list = jsonDecode(raw) as List<dynamic>;
    return list
        .map((item) => Challenge.fromJson(item as Map<String, dynamic>))
        .toList();
  }
}
