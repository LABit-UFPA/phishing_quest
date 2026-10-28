import 'package:get/get.dart';
import 'package:phishing_quest/app/data/models/category.model.dart';
import 'package:phishing_quest/app/data/repositories/category/category_repository.dart';
import 'package:phishing_quest/app/data/repositories/request_repository.dart';
import 'package:phishing_quest/app/data/services/session_router.dart';
import 'package:phishing_quest/app/global_ui/components/toast.dart';

enum GameMode { quiz, emailSim }

class PlayController extends GetxController {
  final RxList<CategoryModel> categories = <CategoryModel>[].obs;
  final Rx<CategoryModel?> selectedCategory = Rx<CategoryModel?>(null);
  final Rx<GameMode?> selectedMode = Rx<GameMode?>(null);
  final RxBool isLoading = true.obs;
  final RxBool isOpeningInbox = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadCategories();
  }

  Future<void> loadCategories() async {
    isLoading.value = true;
    try {
      categories.value = await CategoryRepository().getCategories();
    } on ApiException catch (e) {
      Toast.error('Categorias indisponíveis', e.message);
    }
    isLoading.value = false;
  }

  void selectMode(GameMode mode) {
    selectedMode.value = mode;
    // Reset category selection when changing modes
    selectedCategory.value = null;
  }

  void selectCategory(CategoryModel category) {
    selectedCategory.value = category;
  }

  void startGame() {
    if (selectedMode.value == GameMode.emailSim) {
      startEmailSim();
    } else if (selectedCategory.value != null) {
      Get.toNamed(
        '/game',
        arguments: {
          'categoryId': selectedCategory.value!.id,
          'categoryName': selectedCategory.value!.categoryName,
        },
      );
    }
  }

  Future<void> startEmailSim() async {
    if (isOpeningInbox.value) return;
    isOpeningInbox.value = true;
    await openInbox();
    isOpeningInbox.value = false;
  }
}
