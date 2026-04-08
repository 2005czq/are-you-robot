import 'dart:convert';
import 'dart:math';

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

  String get emoji => switch (this) {
        ChallengeMode.text => '📝',
        ChallengeMode.image => '📸',
        ChallengeMode.video => '🎬',
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

  ChallengeOption copyWith({
    String? id,
    String? label,
    String? sourceType,
    String? text,
    String? asset,
    String? credit,
  }) {
    return ChallengeOption(
      id: id ?? this.id,
      label: label ?? this.label,
      sourceType: sourceType ?? this.sourceType,
      text: text ?? this.text,
      asset: asset ?? this.asset,
      credit: credit ?? this.credit,
    );
  }

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

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'label': label,
      'sourceType': sourceType,
      if (text != null) 'text': text,
      if (asset != null) 'asset': asset,
      if (credit != null) 'credit': credit,
    };
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

  Challenge copyWith({
    String? id,
    ChallengeMode? mode,
    String? title,
    String? prompt,
    String? difficulty,
    String? explanation,
    List<ChallengeOption>? options,
  }) {
    return Challenge(
      id: id ?? this.id,
      mode: mode ?? this.mode,
      title: title ?? this.title,
      prompt: prompt ?? this.prompt,
      difficulty: difficulty ?? this.difficulty,
      explanation: explanation ?? this.explanation,
      options: options ?? this.options,
    );
  }

  factory Challenge.fromJson(Map<String, dynamic> json) {
    return Challenge(
      id: json['id'] as String,
      mode: ChallengeModeX.fromKey(json['mode'] as String),
      title: json['title'] as String,
      prompt: json['prompt'] as String,
      difficulty: json['difficulty'] as String,
      explanation: json['explanation'] as String,
      options: (json['options'] as List<dynamic>)
          .map((option) =>
              ChallengeOption.fromJson(option as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'mode': mode.key,
      'title': title,
      'prompt': prompt,
      'difficulty': difficulty,
      'explanation': explanation,
      'options': options.map((option) => option.toJson()).toList(),
    };
  }

  Challenge shuffledOptions([Random? random]) {
    final labels = List<String>.generate(
      options.length,
      (index) => String.fromCharCode(65 + index),
    );
    final shuffled = List<ChallengeOption>.from(options)
      ..shuffle(random ?? Random());

    return copyWith(
      options: [
        for (var i = 0; i < shuffled.length; i++)
          shuffled[i].copyWith(label: labels[i]),
      ],
    );
  }

  static List<Challenge> decodeList(String raw) {
    final list = jsonDecode(raw) as List<dynamic>;
    return list
        .map((item) => Challenge.fromJson(item as Map<String, dynamic>))
        .toList();
  }
}
