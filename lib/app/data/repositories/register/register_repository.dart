import 'package:phishing_quest/app/data/repositories/register/register_repository.interface.dart';
import 'package:phishing_quest/app/data/repositories/request_repository.dart';

final class RegisterRepository extends RequestRepository implements IRegisterRepository {
  static const String registerAuth = '/users/register';

  /// POST /users/register. A API exige senha com ao menos 8 caracteres
  /// e responde 400 com o motivo quando recusa o cadastro.
  @override
  Future<void> register({
    required String username,
    required String email,
    required String password,
  }) async {
    final response = await client.post(url(registerAuth), {
      'username': username,
      'password': password,
      'email': email,
    });
    dataOrThrow(response);
  }
}
