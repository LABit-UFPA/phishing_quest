import 'package:phishing_quest/app/data/repositories/request_repository.dart';

final class TelemetryRepository extends RequestRepository {
  /// POST /telemetry-events. Cada evento leva um id gerado no app: se o
  /// lote for reenviado depois de uma falha, a API ignora os repetidos.
  Future<void> sendBatch(List<Map<String, dynamic>> events) async {
    dataOrThrow(await client.post(url('/telemetry-events'), {'events': events}));
  }
}
