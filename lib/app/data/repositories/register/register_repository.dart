import 'package:phishing_quest/app/data/repositories/register/register_repository.interface.dart';
import 'package:phishing_quest/app/data/repositories/request_repository.dart';

final class RegisterRepository extends RequestRepository implements IRegisterRepository {
  static const String registerAuth = '/users/register';

  @override
  Future register(
      {required String username,
      required String email,
      required String password}) async {
    final url = apiHelpers.buildUrl(url: registerAuth);

    final bodyRegister = {
      'username': username,
      'password': password,
      'email': email 
    };

    try {
      final response = await client.post(url, bodyRegister);
      final invalidResponse = isValidResponse(response);
      if (!invalidResponse.valid) {
        return invalidResponse;
      }

      return (valid: true, reason: null, data: null);
    } catch (_) {
      return (valid: false, reason: 'Erro interno durante a requisição', data: null);
    }
  }
}
