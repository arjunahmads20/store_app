import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:store_app/src/constants/api_constants.dart';
import 'package:store_app/src/features/membership/domain/membership.dart';
import 'package:store_app/src/features/membership/domain/user_membership_model.dart';
import 'package:store_app/src/features/membership/domain/membership_reward.dart';
import 'package:store_app/src/features/auth/data/auth_repository.dart';

class MembershipRepository {
  final Dio _dio;
  final Ref _ref;

  MembershipRepository(this._dio, this._ref);

  Future<UserMembership?> getUserMembership() async {
    try {
      final response = await _dio.get('/membership/user-memberships/');
      final data = response.data;

      List results = [];
      if (data is Map && data.containsKey('results')) {
        results = data['results'];
      } else if (data is List) {
        results = data;
      }

      if (results.isEmpty) return null;

      return UserMembership.fromJson(results.first);
    } catch (e) {
      throw Exception('Failed to get user membership: $e');
    }
  }

  Future<List<Membership>> getMemberships() async {
    try {
      final response = await _dio.get('/membership/memberships/');
      final data = response.data;
      List list = [];
      if (data is Map && data.containsKey('results')) {
        list = data['results'];
      } else if (data is List) {
        list = data;
      }
      print(data);
      return list.map((e) => Membership.fromJson(e)).toList();
    } catch (e) {
      throw Exception('Failed to load memberships: $e');
    }
  }

  Future<void> claimPointMembershipReward({
    int? pointMembershipRewardId,
  }) async {
    try {
      final data = <String, dynamic>{};
      if (pointMembershipRewardId != null)
        data['point_membership_reward_id'] = pointMembershipRewardId;

      await _dio.post(ApiConstants.userPointMembershipRewards, data: data);
    } catch (e) {
      // Handle known errors (e.g., already claimed)
      if (e is DioException && e.response?.statusCode == 400) {
        throw Exception(
          "You have already claimed this point membership reward or it is unavailable.",
        );
      }
      throw Exception('Failed to claim point membership reward: $e');
    }
  }

  Future<List<MembershipReward>> getMembershipRewards({
    bool? isClaimed = false,
  }) async {
    try {
      final response = await _dio.get(
        '/membership/membership-rewards/',
        queryParameters: {'is_claimed': isClaimed},
      );
      final data = response.data;
      List list = [];
      if (data is Map && data.containsKey('results')) {
        list = data['results'];
      } else if (data is List) {
        list = data;
      }
      return list.map((e) => MembershipReward.fromJson(e)).toList();
    } catch (e) {
      throw Exception('Failed to load membership rewards: $e');
    }
  }
}

final membershipRepositoryProvider = Provider<MembershipRepository>((ref) {
  return MembershipRepository(ref.watch(dioProvider), ref);
});

final userMembershipProvider = FutureProvider<UserMembership?>((ref) async {
  return ref.watch(membershipRepositoryProvider).getUserMembership();
});
