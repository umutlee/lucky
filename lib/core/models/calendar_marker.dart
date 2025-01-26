/// 日曆標記類型
class CalendarMarker {
  /// 標記日期
  final DateTime date;

  /// 標記類型（solar_term: 節氣, lucky_day: 吉日, lunar_festival: 農曆節日, custom: 自定義）
  final String type;

  /// 標記標題
  final String title;

  /// 標記描述
  final String description;

  /// 標記顏色（可選）
  final int? color;

  CalendarMarker({
    required this.date,
    required this.type,
    required this.title,
    required this.description,
    this.color,
  });

  /// 從 JSON 創建
  factory CalendarMarker.fromJson(Map<String, dynamic> json) {
    return CalendarMarker(
      date: DateTime.parse(json['date'] as String),
      type: json['type'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      color: json['color'] as int?,
    );
  }

  /// 轉換為 JSON
  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'type': type,
      'title': title,
      'description': description,
      if (color != null) 'color': color,
    };
  }

  /// 複製並修改
  CalendarMarker copyWith({
    DateTime? date,
    String? type,
    String? title,
    String? description,
    int? color,
  }) {
    return CalendarMarker(
      date: date ?? this.date,
      type: type ?? this.type,
      title: title ?? this.title,
      description: description ?? this.description,
      color: color ?? this.color,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CalendarMarker &&
          runtimeType == other.runtimeType &&
          date.year == other.date.year &&
          date.month == other.date.month &&
          date.day == other.date.day &&
          type == other.type &&
          title == other.title &&
          description == other.description &&
          color == other.color;

  @override
  int get hashCode =>
      date.hashCode ^
      type.hashCode ^
      title.hashCode ^
      description.hashCode ^
      (color ?? 0).hashCode;
} 