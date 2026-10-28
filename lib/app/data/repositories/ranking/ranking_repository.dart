import 'package:phishing_quest/app/data/models/ranking_entry.model.dart';
import 'package:phishing_quest/app/data/models/user_stats.model.dart';
import 'package:phishing_quest/app/data/repositories/ranking/ranking_repository.interface.dart';
import 'package:phishing_quest/app/data/repositories/request_repository.dart';

final class RankingRepository extends RequestRepository implements IRankingRepository {
  /// GET /rankings, global ou da turma (?cohortId=).
  @override
  Future<List<RankingEntryModel>> getRanking({String? cohortId, int limit = 50}) async {
    final data = dataOrThrow(await client.get(url('/rankings'), queryParams: {
      'limit': limit,
      if (cohortId != null) 'cohortId': cohortId,
    }));
    final list = data is Map ? data['ranking'] as List? ?? const [] : const [];
    return list.map((e) => RankingEntryModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  /// GET /me/ranking: posicao no ranking global e no da turma.
  @override
  Future<MyRankingModel> getMyRanking() async {
    final data = dataOrThrow(await client.get(url('/me/ranking')));
    return MyRankingModel.fromJson(data as Map<String, dynamic>);
  }

  /// GET /me/stats: d', c, taxas e acuracia por pista.
  @override
  Future<UserStatsModel> getMyStats() async {
    final data = dataOrThrow(await client.get(url('/me/stats')));
    return UserStatsModel.fromJson(data as Map<String, dynamic>);
  }
}
