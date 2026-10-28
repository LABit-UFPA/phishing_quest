import 'package:phishing_quest/app/data/models/category.model.dart';

abstract class ICategoryRepository {
  Future<List<CategoryModel>> getCategories();
}
