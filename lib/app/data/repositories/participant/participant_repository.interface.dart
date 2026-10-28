import 'package:phishing_quest/app/data/models/participant.model.dart';

abstract interface class IParticipantRepository {
  Future<ParticipantModel?> getMyParticipant();
  Future<void> registerConsent({required String consentVersion, String? cohortCode});
  Future<void> withdrawConsent(String userId);
}
