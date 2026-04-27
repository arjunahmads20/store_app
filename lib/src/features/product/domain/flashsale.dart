import 'package:equatable/equatable.dart';

class Flashsale extends Equatable {
  final String id;
  final String name;
  final DateTime startDateTime;
  final DateTime endDateTime;
  final String? bannerUrl; // Optional banner image

  const Flashsale({
    required this.id,
    required this.name,
    required this.startDateTime,
    required this.endDateTime,
    this.bannerUrl,
  });

  bool get isActive {
    final now = DateTime.now();
    return now.isAfter(startDateTime) && now.isBefore(endDateTime);
  }

  Duration get timeRemaining {
    final now = DateTime.now();
    if (now.isAfter(endDateTime)) return Duration.zero;
    return endDateTime.difference(now);
  }

  @override
  List<Object?> get props => [id, name, startDateTime, endDateTime, bannerUrl];
}
