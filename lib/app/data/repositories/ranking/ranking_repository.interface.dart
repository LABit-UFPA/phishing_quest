import 'package:phishing_quest/app/data/models/ranking_entry.model.dart';
import 'package:phishing_quest/app/data/models/user_stats.model.dart';

abstract class IRankingRepository {
  Future<List<RankingEntryModel>> getRanking({String? cohortId, int limit});
  Future<MyRankingModel> getMyRanking();
  Future<UserStatsModel> getMyStats();
}
