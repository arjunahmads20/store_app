import 'package:equatable/equatable.dart';
import 'package:store_app/src/features/voucher/domain/voucher_models.dart';

abstract class MembershipReward extends Equatable {
  final int id;
  final int forMembershipId;
  final DateTime? datetimeStarted;
  final DateTime? datetimeEnded;
  final String type; // 'point_reward' or 'voucher_reward'

  const MembershipReward({
    required this.id,
    required this.forMembershipId,
    this.datetimeStarted,
    this.datetimeEnded,
    required this.type,
  });

  // ...
  factory MembershipReward.fromJson(Map<String, dynamic> json) {
    final type =
        json['type'] as String? ?? 'point_reward'; // Default or check fields

    if (type == 'voucher_reward' || json.containsKey('voucher_order')) {
      return VoucherOrderMembershipReward.fromJson(json);
    } else {
      return PointMembershipReward.fromJson(json);
    }
  }
}

class PointMembershipReward extends MembershipReward {
  final int pointEarned;

  const PointMembershipReward({
    required super.id,
    required super.forMembershipId,
    super.datetimeStarted,
    super.datetimeEnded,
    required this.pointEarned,
  }) : super(type: 'point_reward');

  factory PointMembershipReward.fromJson(Map<String, dynamic> json) {
    return PointMembershipReward(
      id: json['id'] as int,
      forMembershipId: json['for_membership'] as int,
      datetimeStarted: json['datetime_started'] != null
          ? DateTime.tryParse(json['datetime_started'] as String)
          : null,
      datetimeEnded: json['datetime_ended'] != null
          ? DateTime.tryParse(json['datetime_ended'] as String)
          : null,
      pointEarned: json['point_earned'] as int? ?? 0,
    );
  }

  @override
  List<Object?> get props => [id, forMembershipId, pointEarned, type];
}

class VoucherOrderMembershipReward extends MembershipReward {
  final int voucherOrderId;
  final VoucherOrder? voucherOrder; // Expanded if available

  const VoucherOrderMembershipReward({
    required super.id,
    required super.forMembershipId,
    super.datetimeStarted,
    super.datetimeEnded,
    required this.voucherOrderId,
    this.voucherOrder,
  }) : super(type: 'voucher_reward');

  factory VoucherOrderMembershipReward.fromJson(Map<String, dynamic> json) {
    VoucherOrder? voucher;
    int vId;

    if (json['voucher_order'] is Map) {
      voucher = VoucherOrder.fromJson(json['voucher_order']);
      vId = voucher.id;
    } else {
      vId = json['voucher_order'] as int;
    }

    return VoucherOrderMembershipReward(
      id: json['id'] as int,
      forMembershipId: json['for_membership'] as int,
      datetimeStarted: json['datetime_started'] != null
          ? DateTime.tryParse(json['datetime_started'] as String)
          : null,
      datetimeEnded: json['datetime_ended'] != null
          ? DateTime.tryParse(json['datetime_ended'] as String)
          : null,
      voucherOrderId: vId,
      voucherOrder: voucher,
    );
  }

  @override
  List<Object?> get props => [id, forMembershipId, voucherOrderId, type];
}
