import 'package:phishing_quest/app/data/models/user.model.dart';

abstract interface class ILoginRepository {
  Future<({String token, UserModel user})> login({required String email, required String password});
}
