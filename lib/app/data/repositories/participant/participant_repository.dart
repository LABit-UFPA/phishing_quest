import 'package:phishing_quest/app/data/models/participant.model.dart';
import 'package:phishing_quest/app/data/repositories/participant/participant_repository.interface.dart';
import 'package:phishing_quest/app/data/repositories/request_repository.dart';

final class ParticipantRepository extends RequestRepository implements IParticipantRepository {
  /// GET /me/participant. Devolve null quando o usuario nunca consentiu.
  @override
  Future<ParticipantModel?> getMyParticipant() async {
    final response = await client.get(url('/me/participant'));
    if (response.statusCode == 404) {
      return null;
    }
    return ParticipantModel.fromJson(dataOrThrow(response) as Map<String, dynamic>);
  }

  /// POST /auth/consent com a versao do termo e, opcionalmente, o codigo
  /// da turma. O servidor sorteia a condicao experimental; consentir de
  /// novo depois de retirar mantem a condicao sorteada da primeira vez.
  @override
  Future<void> registerConsent({required String consentVersion, String? cohortCode}) async {
    dataOrThrow(await client.post(url('/auth/consent'), {
      'consentVersion': consentVersion,
      if (cohortCode != null && cohortCode.trim().isNotEmpty) 'cohortCode': cohortCode.trim(),
    }));
  }

  /// POST /auth/consent/:id/withdraw. Depois disso a API recusa novas
  /// tentativas e o export deixa o participante de fora.
  @override
  Future<void> withdrawConsent(String userId) async {
    dataOrThrow(await client.post(url('/auth/consent/$userId/withdraw'), null));
  }
}
