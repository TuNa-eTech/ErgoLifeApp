import 'package:equatable/equatable.dart';

/// Data for a single day in the daily breakdown chart.
class DailyBreakdownModel extends Equatable {
  final String date;
  final int points;
  final int duration;
  final int count;

  const DailyBreakdownModel({
    required this.date,
    required this.points,
    required this.duration,
    required this.count,
  });

  factory DailyBreakdownModel.fromJson(Map<String, dynamic> json) {
    return DailyBreakdownModel(
      date: json['date'] as String,
      points: json['points'] as int? ?? 0,
      duration: json['duration'] as int? ?? 0,
      count: json['count'] as int? ?? 0,
    );
  }

  /// Day of week label (Mon, Tue, etc.)
  String get dayLabel {
    try {
      final d = DateTime.parse(date);
      const labels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
      return labels[d.weekday - 1];
    } catch (_) {
      return '';
    }
  }

  @override
  List<Object?> get props => [date, points, duration, count];
}

/// Heatmap cell for GitHub-style activity grid.
class HeatmapDataModel extends Equatable {
  final String date;
  final int intensity;
  final int count;
  final int points;

  const HeatmapDataModel({
    required this.date,
    required this.intensity,
    required this.count,
    required this.points,
  });

  factory HeatmapDataModel.fromJson(Map<String, dynamic> json) {
    return HeatmapDataModel(
      date: json['date'] as String,
      intensity: json['intensity'] as int? ?? 0,
      count: json['count'] as int? ?? 0,
      points: json['points'] as int? ?? 0,
    );
  }

  @override
  List<Object?> get props => [date, intensity, count, points];
}
