import 'package:get/get.dart';
import 'package:phishing_quest/app/data/models/category.model.dart';
import 'package:phishing_quest/app/data/models/user_stats.model.dart';
import 'package:phishing_quest/app/data/repositories/category/category_repository.dart';
import 'package:phishing_quest/app/data/repositories/ranking/ranking_repository.dart';
import 'package:phishing_quest/app/data/repositories/request_repository.dart';
import 'package:phishing_quest/app/data/services/auth_service.dart';

class DashboardController extends GetxController {
  final AuthService authService = Get.find<AuthService>();
  final RxList<CategoryModel> categories = <CategoryModel>[].obs;
  final Rx<UserStatsModel?> stats = Rx<UserStatsModel?>(null);
  final RxBool isLoading = true.obs;

  /// Posicao no ranking global; null para quem nao e participante.
  final RxnInt userRank = RxnInt();

  @override
  void onInit() {
    super.onInit();
    loadData();
  }

  Future<void> loadData() async {
    isLoading.value = true;
    try {
      final rankingRepo = RankingRepository();
      categories.value = await CategoryRepository().getCategories();
      stats.value = await rankingRepo.getMyStats();
      final global = (await rankingRepo.getMyRanking()).global;
      userRank.value = global?.position;
      if (global != null) {
        await authService.updateScore(global.score);
      }
    } on ApiException {
      // O inicio mostra o que conseguiu carregar; as outras abas mostram
      // o erro com detalhe.
    }
    isLoading.value = false;
  }
}
