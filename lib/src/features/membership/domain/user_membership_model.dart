class UserMembership {
  final int user;
  final int membership; // ID of the membership tier
  final int point;
  final int levelUpPoint;
  final String referralCode;
  final DateTime? datetimeAttached;
  final DateTime? datetimeEnded;

  UserMembership({
    required this.user,
    required this.membership,
    required this.point,
    required this.levelUpPoint,
    required this.referralCode,
    this.datetimeAttached,
    this.datetimeEnded,
  });

  factory UserMembership.fromJson(Map<String, dynamic> json) {
    return UserMembership(
      user: json['user'] as int,
      membership: json['membership'] as int,
      point: json['point'] as int? ?? 0,
      levelUpPoint: json['level_up_point'] as int? ?? 0,
      referralCode: json['referal_code'] as String? ?? '',
      datetimeAttached: json['datetime_attached'] != null
          ? DateTime.tryParse(json['datetime_attached'])
          : null,
      datetimeEnded: json['datetime_ended'] != null
          ? DateTime.tryParse(json['datetime_ended'])
          : null,
    );
  }
}
