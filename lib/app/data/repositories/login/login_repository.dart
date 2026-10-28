import 'package:phishing_quest/app/data/models/user.model.dart';
import 'package:phishing_quest/app/data/repositories/request_repository.dart';
import 'login_repository.interface.dart';

final class LoginRepository extends RequestRepository implements ILoginRepository {
  static const String loginUrlProduction = '/users/login';

  /// POST /users/login devolve o JWT e o perfil (id, username, email,
  /// role, totalScore). Lanca [ApiException] com 401 quando email ou
  /// senha nao conferem.
  @override
  Future<({String token, UserModel user})> login({
    required String email,
    required String password,
  }) async {
    final response = await client.post(url(loginUrlProduction), {
      'email': email,
      'password': password,
    });
    if (response.statusCode == 401) {
      throw const ApiException(401, 'E-mail ou senha inválidos');
    }

    final data = dataOrThrow(response) as Map<String, dynamic>;
    final token = data['token'] as String? ?? '';
    if (token.isEmpty) {
      throw const ApiException(null, 'O servidor não devolveu o token de acesso');
    }
    return (token: token, user: UserModel.fromJson(data));
  }
}
