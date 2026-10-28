import 'package:get/get.dart';
import 'package:phishing_quest/app/data/models/ranking_entry.model.dart';
import 'package:phishing_quest/app/data/repositories/ranking/ranking_repository.dart';
import 'package:phishing_quest/app/data/repositories/request_repository.dart';

enum RankingScope { global, cohort }

/// Ranking dos pontos do quiz, global ou da turma do participante.
class RankingController extends GetxController {
  final RxList<RankingEntryModel> ranking = <RankingEntryModel>[].obs;
  final Rx<MyRankingModel?> mine = Rx<MyRankingModel?>(null);
  final Rx<RankingScope> scope = RankingScope.global.obs;
  final RxBool isLoading = true.obs;
  final RxnString loadError = RxnString();

  final RankingRepository _repository = RankingRepository();

  bool get hasCohort => mine.value?.cohortId != null;

  RankingEntryModel? get myRank => scope.value == RankingScope.cohort ? mine.value?.cohort : mine.value?.global;

  @override
  void onInit() {
    super.onInit();
    loadRanking();
  }

  Future<void> loadRanking() async {
    isLoading.value = true;
    loadError.value = null;
    try {
      mine.value = await _repository.getMyRanking();
      if (scope.value == RankingScope.cohort && !hasCohort) {
        scope.value = RankingScope.global;
      }
      ranking.value = await _repository.getRanking(
        cohortId: scope.value == RankingScope.cohort ? mine.value?.cohortId : null,
      );
    } on ApiException catch (e) {
      loadError.value = e.message;
    }
    isLoading.value = false;
  }

  void setScope(RankingScope value) {
    if (scope.value == value) return;
    scope.value = value;
    loadRanking();
  }
}
