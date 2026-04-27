class Membership {
  final int id;
  final int level;
  final String name;
  final String? description;
  final int minPointEarned;
  final String? next_membership_name;

  Membership({
    required this.id,
    required this.level,
    required this.name,
    this.description,
    required this.minPointEarned,
    this.next_membership_name,
  });

  factory Membership.fromJson(Map<String, dynamic> json) {
    return Membership(
      id: json['id'] as int,
      level: json['level'] as int,
      name: json['name'] as String,
      description: json['description'] as String?,
      minPointEarned: json['min_point_earned'] as int,
      next_membership_name: json['next_membership_name'] as String?,
    );
  }
}
