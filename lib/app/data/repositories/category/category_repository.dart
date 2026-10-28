import 'package:phishing_quest/app/data/models/category.model.dart';
import 'package:phishing_quest/app/data/repositories/category/category_repository.interface.dart';
import 'package:phishing_quest/app/data/repositories/request_repository.dart';

final class CategoryRepository extends RequestRepository implements ICategoryRepository {
  @override
  Future<List<CategoryModel>> getCategories() async {
    final data = dataOrThrow(await client.get(url('/categories')));
    final list = data is List ? data : const [];
    return list.map((e) => CategoryModel.fromJson(e as Map<String, dynamic>)).toList();
  }
}
